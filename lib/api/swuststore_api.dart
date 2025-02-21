import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:swustmeow/entity/feature_suggestion.dart';
import 'package:swustmeow/entity/soa/course/courses_container.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/status.dart';

import '../components/suggestion/suggestion_filter_option.dart';
import '../components/suggestion/suggestion_sort_option.dart';
import '../entity/response_entity.dart';
import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/course_type.dart';

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

    final base = 'http://[2408:8266:2b04:81be:946f:ad98:5d3a:a2c8]:8090' ??
        info.pyServerUrl;
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

  /// 取消功能建议投票
  ///
  /// 参数:
  ///   suggestionId: 要取消投票的建议的 ID
  ///   userId: 用户 ID
  ///
  /// 返回值: 包含新投票数的状态容器。
  static Future<StatusContainer<dynamic>> unvoteSuggestion(
      int suggestionId, String userId) async {
    final result = await getBackendApiResponse(
      'DELETE',
      '/api/suggestions/$suggestionId/vote',
      data: {
        'user_id': userId,
      },
    );

    if (result == null) return StatusContainer(Status.fail, 0);

    final code = result.code;
    if (code != 200) {
      final message = result.message as String?;
      return StatusContainer(Status.fail, message ?? '取消投票失败');
    }

    final data = result.data as Map<String, dynamic>?;
    final votesCount = data?['votes_count'] as int?;
    if (votesCount == null) {
      return StatusContainer(Status.fail, '取消投票失败');
    }

    return StatusContainer(Status.ok, votesCount);
  }

  /// 上传课程表
  ///
  /// 将用户的课程表数据上传到后端服务器。
  /// 如果上传成功，返回成功状态；否则，返回错误信息。
  ///
  /// 参数:
  ///   userId: 用户ID
  ///   coursesContainers: 课程表容器列表，包含不同类型和学期的课程
  ///
  /// 返回值: 包含上传结果的状态容器
  static Future<StatusContainer<String>> uploadCourseTable(
    String userId,
    List<CoursesContainer> coursesContainers,
  ) async {
    try {
      // 将课程表容器列表转换为 JSON
      final coursesContainersJson = coursesContainers
          .map((container) => {
                'type': container.type.name,
                'term': container.term,
                'entries':
                    container.entries.map((entry) => entry.toJson()).toList(),
              })
          .toList();

      final coursesContainersStr = jsonEncode(coursesContainersJson);

      final result = await getBackendApiResponse(
        'POST',
        '/api/course_table',
        data: {
          'user_id': userId,
          'course_table': coursesContainersStr,
        },
      );

      if (result == null) {
        return StatusContainer(Status.fail, '课程表上传失败');
      }

      final code = result.code;
      if (code != 200) {
        final message = result.message as String?;
        return StatusContainer(Status.fail, message ?? '课程表上传失败');
      }

      final data = result.data as Map<String, dynamic>?;
      final successMessage = data?['message'] as String?;
      return StatusContainer(Status.ok, successMessage ?? '课程表上传成功');
    } catch (e) {
      return StatusContainer(Status.fail, '课程表上传失败：$e');
    }
  }

  /// 创建课程表分享码
  ///
  /// 返回一个30分钟内有效的四字符分享码
  static Future<StatusContainer<dynamic>> createCourseShareCode(
    String userId,
  ) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/course_table/share',
      data: {
        'user_id': userId,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '创建分享码失败');
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, result.message);
    }

    final data = result.data as Map<String, dynamic>;
    return StatusContainer(Status.ok, {
      'code': data['code'] as String,
      'should_upload': data['should_upload'] as bool,
      'expires_at': data['expires_at'] as String,
    });
  }

  /// 通过分享码访问课程表
  ///
  /// 返回分享者的课程表容器列表
  static Future<StatusContainer<dynamic>> accessSharedCourseTable(
    String userId,
    String shareCode,
  ) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/course_table/share/$shareCode',
      data: {
        'user_id': userId,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '访问共享课表失败');
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, result.message);
    }

    final data = result.data as Map<String, dynamic>;
    final containers = (data['containers'] as List)
        .map((c) => CoursesContainer(
              id: c['id'] as String,
              type: CourseType.values
                  .singleWhere((t) => t.name == c['type'] as String),
              term: c['term'] as String,
              entries: (c['entries'] as List)
                  .map((e) => CourseEntry.fromJson(e as Map<String, dynamic>))
                  .toList(),
              sharerId: c['sharer_id'] as String,
            ))
        .toList();
    return StatusContainer(Status.ok, containers);
  }

  /// 控制课程表共享权限
  ///
  /// [userId] 分享者ID
  /// [viewerId] 可选，指定查看者ID。如果为null则控制所有查看者的权限
  /// [enabled] 是否启用共享
  static Future<StatusContainer<String>> controlCourseShare(
    String userId, {
    String? viewerId,
    required bool enabled,
  }) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/course_table/share/control',
      data: {
        'user_id': userId,
        if (viewerId != null) 'viewer_id': viewerId,
        'enabled': enabled,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '更新共享权限失败');
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, result.message);
    }

    return StatusContainer(Status.ok, '共享权限更新成功');
  }

  /// 获取共享的课程表
  ///
  /// [containerId] 课程表容器ID
  /// [userId] 查看者ID
  static Future<StatusContainer<dynamic>> getSharedCourseTable(
    String containerId,
    String userId,
  ) async {
    final result = await getBackendApiResponse(
      'GET',
      '/api/course_table/shared/$containerId',
      queryParameters: {
        'user_id': userId,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '获取共享课表失败');
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, result.message);
    }

    try {
      final data = result.data as Map<String, dynamic>;
      final container = data['container'] as Map<String, dynamic>;
      return StatusContainer(
        Status.ok,
        CoursesContainer(
          id: container['id'] as String,
          type: CourseType.values
              .singleWhere((t) => t.name == container['type'] as String),
          term: container['term'] as String,
          entries: (container['entries'] as List)
              .map((e) => CourseEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
          sharerId: container['sharer_id'] as String,
        ),
      );
    } catch (e) {
      return StatusContainer(Status.fail, '解析课表数据失败：$e');
    }
  }

  /// 获取共享用户列表
  static Future<StatusContainer<dynamic>> getSharedUsers(
    String userId,
  ) async {
    final result = await getBackendApiResponse(
      'GET',
      '/api/course_table/share/users',
      queryParameters: {
        'user_id': userId,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '获取共享用户列表失败');
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, result.message);
    }

    try {
      final data = result.data as Map<String, dynamic>;
      final users = (data['users'] as List).cast<Map<String, dynamic>>();
      return StatusContainer(Status.ok, users);
    } catch (e) {
      return StatusContainer(Status.fail, '解析用户数据失败：$e');
    }
  }

  /// 获取用户的全局共享状态
  static Future<StatusContainer<bool>> getCourseShareStatus(
    String userId,
  ) async {
    final result = await getBackendApiResponse(
      'GET',
      '/api/course_table/share/status',
      queryParameters: {
        'user_id': userId,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, false);
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, false);
    }

    try {
      final data = result.data as Map<String, dynamic>;
      return StatusContainer(Status.ok, data['enabled'] as bool);
    } catch (e) {
      return StatusContainer(Status.fail, false);
    }
  }

  /// 更新用户的全局共享状态
  static Future<StatusContainer<String>> updateCourseShareStatus(
    String userId,
    bool enabled,
  ) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/course_table/share/status',
      data: {
        'user_id': userId,
        'enabled': enabled.toString(),
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '更新共享状态失败');
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, result.message);
    }

    return StatusContainer(Status.ok, '更新成功');
  }
}
