import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:swustmeow/entity/feature_suggestion.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/status.dart';

import '../components/suggestion/suggestion_filter_option.dart';
import '../components/suggestion/suggestion_sort_option.dart';
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
      return ResponseEntity(code: 500, message: '无法拉取数据，请稍后再试');
    }

    return resp.data != null
        ? ResponseEntity.fromJson(resp.data as Map<String, dynamic>)
        : null;
  }

  /// 获取验证码 OCR 识别结果
  ///
  /// 将 Base64 编码的验证码图片发送到后端 API 进行 OCR 识别。
  /// 如果识别成功，返回一个包含 OCR 文本结果的状态容器；
  /// 否则，返回一个带有错误信息的文本的状态容器。
  ///
  /// 参数:
  ///   captchaBase64: Base64 编码的验证码图片字符串。
  ///
  /// 返回值: 包含 OCR 识别结果的状态容器。
  static Future<StatusContainer<String>> getCaptcha(
      String captchaBase64) async {
    final result = await getBackendApiResponse('POST', '/api/captcha', data: {
      'image': captchaBase64,
    });
    if (result == null) return StatusContainer(Status.fail, '验证码获取失败');

    final data = result.data as Map<String, dynamic>?;
    final captcha = data?['captcha'] as String?;
    return StatusContainer(
        captcha != null ? Status.ok : Status.fail, captcha ?? '验证码识别失败');
  }

  /// 创建建议
  ///
  /// 将用户提出的建议发送到后端 API 进行创建。
  /// 如果创建成功，返回一个包含创建结果的状态容器；
  /// 否则，返回一个带有错误信息的文本的状态容器。
  ///
  /// 参数:
  ///   - content: 建议内容。
  ///   - creatorId: 创建者 ID。
  ///
  /// 返回值: 包含创建结果或错误信息字符串的状态容器。
  static Future<StatusContainer<dynamic>> createSuggestion(
      String content, String creatorId) async {
    final result =
        await getBackendApiResponse('POST', '/api/suggestions', data: {
      'content': content,
      'creator_id': creatorId,
    });
    if (result == null) return StatusContainer(Status.fail, '建议创建失败');

    final code = result.code;
    if (code != 200) {
      final message = result.message as String?;
      return StatusContainer(Status.fail, message ?? '建议创建失败');
    }
    final data = result.data as Map<String, dynamic>;
    final id = data['id'] as int?;
    final createdAt = data['created_at'] as String?;

    if (id == null || createdAt == null) {
      return StatusContainer(Status.fail, '未知错误');
    }

    return StatusContainer(
      Status.ok,
      FeatureSuggestion(
        id: id,
        content: content,
        creatorId: creatorId,
        votesCount: 0,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
        isCompleted: false,
      ),
    );
  }

  /// 获取功能建议列表
  ///
  /// [page] 页码，从1开始
  /// [perPage] 每页数量
  /// [sort] 排序方式
  /// [userId] 用户ID，用于判断是否已投票
  static Future<StatusContainer<dynamic>> getSuggestions({
    required String userId,
    int page = 1,
    int perPage = 10,
    SuggestionSortOption sort = SuggestionSortOption.timeDesc,
    SuggestionFilterOption filter = SuggestionFilterOption.all,
  }) async {
    final result = await getBackendApiResponse(
      'GET',
      '/api/suggestions',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'sort': sort.value,
        'filter': filter.value,
        'user_id': userId,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '建议获取失败');
    }

    final code = result.code;
    if (code != 200) {
      final message = result.message;
      return StatusContainer(Status.fail, message);
    }

    final data = result.data as Map<String, dynamic>?;
    List<Map<String, dynamic>>? suggestions =
        (data?['suggestions'] as List<dynamic>?)?.cast();
    final pagination = data?['pagination'] as Map<String, dynamic>?;

    if (suggestions == null || pagination == null) {
      return StatusContainer(Status.fail, '建议获取失败');
    }

    final list = suggestions.map((s) => FeatureSuggestion.fromJson(s)).toList();

    return StatusContainer(Status.ok, {
      'suggestions': list,
      'pagination': pagination,
    });
  }

  /// 删除建议反馈
  ///
  /// 从后端 API 删除指定的建议反馈。
  ///
  /// 参数:
  ///   suggestionId: 要删除的建议的 ID。
  ///   userId: 用户 ID，用于验证删除权限。
  ///
  /// 返回值: 删除结果。
  static Future<StatusContainer<String?>> deleteSuggestion(
      int suggestionId, String userId) async {
    final result = await getBackendApiResponse(
      'DELETE',
      '/api/suggestions/$suggestionId',
      data: {
        'user_id': userId,
      },
    );

    if (result == null) return StatusContainer(Status.fail, '建议删除失败');

    final code = result.code;
    if (code != 200) {
      final message = result.message as String?;
      return StatusContainer(Status.fail, message ?? '建议删除失败');
    }

    return StatusContainer(Status.ok);
  }

  /// 完成功能建议（仅管理员可用）
  ///
  /// 参数:
  ///   suggestionId: 要完成的建议的 ID
  ///   userId: 用户 ID，用于验证管理员权限
  ///
  /// 返回值: 完成结果。
  static Future<StatusContainer<String?>> completeSuggestion(
      int suggestionId, String userId) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/suggestions/$suggestionId/complete',
      data: {
        'user_id': userId,
      },
    );

    if (result == null) return StatusContainer(Status.fail, '建议完成失败');

    final code = result.code;
    if (code != 200) {
      final message = result.message as String?;
      return StatusContainer(Status.fail, message ?? '建议完成失败');
    }

    return StatusContainer(Status.ok);
  }

  /// 设置功能建议为正在实现状态（仅管理员可用）
  ///
  /// 参数:
  ///   suggestionId: 要设置的建议的 ID
  ///   userId: 用户 ID，用于验证管理员权限
  ///   working: 是否正在实现
  ///
  /// 返回值: 设置结果。
  static Future<StatusContainer<String?>> setSuggestionWorking(
      int suggestionId, String userId, bool working) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/suggestions/$suggestionId/working',
      data: {
        'user_id': userId,
        'working': working,
      },
    );

    if (result == null) return StatusContainer(Status.fail, '设置状态失败');

    final code = result.code;
    if (code != 200) {
      final message = result.message as String?;
      return StatusContainer(Status.fail, message ?? '设置状态失败');
    }

    return StatusContainer(Status.ok);
  }

  /// 为功能建议投票
  ///
  /// 参数:
  ///   suggestionId: 要投票的建议的 ID
  ///   userId: 用户 ID
  ///
  /// 返回值: 包含新投票数的状态容器。
  static Future<StatusContainer<dynamic>> voteSuggestion(
      int suggestionId, String userId) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/suggestions/$suggestionId/vote',
      data: {
        'user_id': userId,
      },
    );

    if (result == null) return StatusContainer(Status.fail, 0);

    final code = result.code;
    if (code != 200) {
      final message = result.message as String?;
      return StatusContainer(Status.fail, message ?? '投票失败');
    }

    final data = result.data as Map<String, dynamic>?;
    final votesCount = data?['votes_count'] as int?;
    if (votesCount == null) {
      return StatusContainer(Status.fail, '投票失败');
    }

    return StatusContainer(Status.ok, votesCount);
  }
}
