import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/status.dart';

import '../entity/response_entity.dart';

class SWUSTStoreApiService {
  static const _hmacSecretKey =
      'REDACTED_SWUSTSTORE_SERVER_HMAC_SECRET';
  static const _aesSecretKey = 'REDACTED_SWUSTSTORE_SERVER_AES_SECRET';
  static encrypt.Key? _aesKey;
  static encrypt.IV? _aesIV;
  static encrypt.Encrypter? _aesEncrypter;

  static void init() {
    _aesKey ??= encrypt.Key.fromBase64(_aesSecretKey);
    _aesIV ??= encrypt.IV.fromLength(16);
    _aesEncrypter ??= encrypt.Encrypter(encrypt.Fernet(_aesKey!));
  }

  /// 生成 HMAC-SHA256 签名
  static String _generateSignature(String timestamp) {
    var key = utf8.encode(_hmacSecretKey);
    var bytes = utf8.encode(timestamp);
    var hmacSha256 = Hmac(sha256, key);
    return hmacSha256.convert(bytes).toString();
  }

  /// AES 加密
  static String _encryptData(String data) {
    return base64.encode(_aesEncrypter!.encrypt(data, iv: _aesIV).bytes);
  }

  /// 获取后端 API 响应，添加 HMAC 认证 & AES 加密
  static Future<ResponseEntity<T>?> getBackendApiResponse<T>(
    final String method,
    final String path, {
    final Dio? client,
    final Object? data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
  }) async {
    final dio = client ??
        Dio(
          BaseOptions(
            persistentConnection: false,
            sendTimeout: Duration(seconds: 5),
            receiveTimeout: Duration(seconds: 10),
          ),
        );

    final info = GlobalService.serverInfo;
    if (info == null) {
      return ResponseEntity(code: 500, message: '无法拉取数据，请稍后再试');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = _generateSignature(timestamp);

    final jsonHeaders = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'X-Timestamp': timestamp,
      'X-Signature': signature,
    };

    final encryptedData = data != null
        ? {
            for (var key in (data as Map<String, dynamic>).keys)
              key: _encryptData(data[key].toString())
          }
        : null;

    final base = info.pyServerUrl;
    final resp = await dio.request(
      '$base$path',
      data: encryptedData,
      queryParameters: queryParameters,
      options: options == null
          ? Options(
              method: method, validateStatus: (_) => true, headers: jsonHeaders)
          : options.copyWith(
              method: method,
              validateStatus: (_) => true,
              headers: jsonHeaders,
            ),
    );

    if (resp.data is! Map<String, dynamic>) {
      return ResponseEntity(code: 500, message: '服务器开小差啦，请稍后再试~');
    }

    return resp.data != null
        ? ResponseEntity.fromJson(resp.data as Map<String, dynamic>)
        : null;
  }

  static Future<StatusContainer<String>> getCaptcha(String captchaBase64) async {
    final result = await getBackendApiResponse('POST', '/api/captcha', data: {
      'image': captchaBase64,
    });
    if (result == null) return StatusContainer(Status.fail, '验证码获取失败');

    final data = result.data as Map<String, dynamic>?;
    final captcha = data?['captcha'] as String?;
    return StatusContainer(
        captcha != null ? Status.ok : Status.fail, captcha ?? '验证码识别失败');
  }
}
