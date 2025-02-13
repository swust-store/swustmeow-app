import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:swustmeow/services/global_service.dart';

import '../entity/response_entity.dart';
import '../entity/soa/course/course_entry.dart';
import '../utils/status.dart';

class SWUSTStoreApiService {
  static const _hmacSecretKey =
      'REDACTED_SWUSTSTORE_SERVER_HMAC_SECRET';
  static const _aesSecretKey = 'REDACTED_SWUSTSTORE_SERVER_AES_SECRET';
  static late final encrypt.Key _aesKey;
  static late final encrypt.IV _aesIV;
  static late final encrypt.Encrypter _aesEncrypter;

  static void init() {
    _aesKey = encrypt.Key.fromBase64(_aesSecretKey);
    _aesIV = encrypt.IV.fromLength(16);
    _aesEncrypter = encrypt.Encrypter(encrypt.Fernet(_aesKey));
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
    return base64.encode(_aesEncrypter.encrypt(data, iv: _aesIV).bytes);
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
      return ResponseEntity(code: 500, message: '无法从服务器拉取数据，请稍后再试~');
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

    final base = info.backendApiUrl;
    final resp = await dio.request('$base$path',
        data: encryptedData,
        queryParameters: queryParameters,
        options: options == null
            ? Options(
                method: method,
                validateStatus: (_) => true,
                headers: jsonHeaders)
            : options.copyWith(
                method: method,
                validateStatus: (_) => true,
                headers: jsonHeaders));

    if (resp.data is! Map<String, dynamic>) {
      return ResponseEntity(code: 500, message: '服务器开小差啦，请稍后再试~');
    }

    return resp.data != null
        ? ResponseEntity.fromJson(resp.data as Map<String, dynamic>)
        : null;
  }

  /// 登录到一站式系统并获取凭证 (TGC)
  static Future<StatusContainer<String>> loginToSOA(
    String username,
    String password,
  ) async {
    try {
      final response = await getBackendApiResponse('POST', '/api/s/login',
          data: {'username': username, 'password': password});
      if (response == null || response.code != 200) {
        return StatusContainer(Status.fail, response?.message);
      }
      return StatusContainer(Status.ok, response.data as String);
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '内部错误：${e.toString()}');
    }
  }

  /// 获取实验课课程表
  static Future<StatusContainer<dynamic>> getExperimentCourseEntries(
    String tgc,
    String term,
  ) async {
    var fixedTerm = term;
    final shouldFix = int.tryParse(fixedTerm.characters.last) == null;
    if (shouldFix) {
      final [s, e, i] = fixedTerm.split('-');
      fixedTerm = '$s-$e-${i == '上' ? '1' : '2'}';
    }

    final response = await getBackendApiResponse(
      'GET',
      '/api/s/get_experiment_course_table',
      queryParameters: {
        'TGC': _encryptData(tgc),
        'term': _encryptData(fixedTerm)
      },
    );

    if (response == null || response.code != 200 || response.data == null) {
      return StatusContainer(Status.fail, response?.message);
    }

    List<Map<String, dynamic>> data = (response.data as List<dynamic>).cast();
    List<CourseEntry> entries = [];
    for (final entryJson in data) {
      final entry = CourseEntry.fromJson(entryJson);
      entries.add(entry);
    }

    return StatusContainer(Status.ok, entries);
  }

  /// 获取对分易课程匹配结果
  static Future<StatusContainer<dynamic>> getDuiFenECoursesMatch(
    List<String> duiFenECourses,
    List<String> courses,
  ) async {
    try {
      final response = await getBackendApiResponse(
        'POST',
        '/api/s/match_duifene_courses',
        data: {
          'duifene_courses': json.encode(duiFenECourses),
          'courses': json.encode(courses)
        },
      );
      if (response == null || response.code != 200) {
        return StatusContainer(Status.fail, response?.message);
      }
      return StatusContainer(Status.ok, response.data as Map<String, dynamic>);
    } on Exception catch (e, st) {
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '内部错误：${e.toString()}');
    }
  }
}
