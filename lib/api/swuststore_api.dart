import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:swustmeow/config.dart';
import 'package:swustmeow/entity/feature_suggestion.dart';
import 'package:swustmeow/entity/soa/course/courses_container.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/status.dart';

import '../components/suggestion/suggestion_filter_option.dart';
import '../components/suggestion/suggestion_sort_option.dart';
import '../entity/ai/ai_chat_message.dart';
import '../entity/response_entity.dart';
import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/course_type.dart';
import '../entity/feature_suggestion_status.dart';

class SWUSTStoreApiService {
  static encrypt.Key? _aesKey;
  static encrypt.IV? _aesIV;
  static encrypt.Encrypter? _aesEncrypter;

  static void init() {
    _aesKey ??= encrypt.Key.fromBase64(Config.swuststoreServerAESSecretKey);
    _aesIV ??= encrypt.IV.fromLength(16);
    _aesEncrypter ??= encrypt.Encrypter(encrypt.Fernet(_aesKey!));
  }

  /// 生成 HMAC-SHA256 签名
  static String _generateSignature(String timestamp) {
    var key = utf8.encode(Config.swuststoreServerHMACSecretKey);
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
    final Map<String, dynamic>? headers,
  }) async {
    try {
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
        ...(headers ?? {})
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
                method: method,
                validateStatus: (_) => true,
                headers: jsonHeaders,
              )
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
    } on Exception catch (e, st) {
      debugPrint('获取后端请求失败（$path）：$e');
      debugPrintStack(stackTrace: st);
      return ResponseEntity(code: 500, message: '无法拉取数据，请稍后再试');
    }
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
    if (result == null) {
      return StatusContainer(Status.manualCaptchaRequired, captchaBase64);
    }

    final data = result.data as Map<String, dynamic>?;
    final captcha = data?['captcha'] as String?;
    return StatusContainer(
      captcha != null ? Status.ok : Status.manualCaptchaRequired,
      captcha ?? captchaBase64,
    );
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

  /// 设置功能建议状态（仅管理员可用）
  ///
  /// 参数:
  ///   suggestionId: 要设置的建议的 ID
  ///   userId: 用户 ID，用于验证管理员权限
  ///   status: 要设置的状态
  ///
  /// 返回值: 设置结果。
  static Future<StatusContainer<String?>> setSuggestionStatus(
      int suggestionId, String userId, SuggestionStatus status) async {
    final result = await getBackendApiResponse(
      'POST',
      '/api/suggestions/$suggestionId/status',
      data: {
        'user_id': userId,
        'status': status.value.toString(),
      },
      headers: {'X-API-Version': '2'},
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

  /// 删除共享的课程表（取消别人分享给我的课表）
  ///
  /// 参数:
  ///   containerId: 要删除的课程表容器ID
  ///   userId: 用户ID
  ///
  /// 返回值: 删除结果。
  static Future<StatusContainer<String?>> removeSharedCourseTable(
      String containerId, String userId) async {
    final result = await getBackendApiResponse(
      'DELETE',
      '/api/course_table/shared/$containerId',
      data: {
        'user_id': userId,
      },
    );

    if (result == null) return StatusContainer(Status.fail, '取消共享失败');

    final code = result.code;
    if (code != 200) {
      final message = result.message as String?;
      return StatusContainer(Status.fail, message ?? '取消共享失败');
    }

    return StatusContainer(Status.ok);
  }

  /// 获取所有被共享的课程表
  ///
  /// [userId] 查看者ID
  /// 返回值: 包含所有共享课程表的状态容器
  static Future<StatusContainer<dynamic>> getAllSharedCourseTables(
    String userId,
  ) async {
    final result = await getBackendApiResponse(
      'GET',
      '/api/course_table/shared',
      queryParameters: {
        'user_id': userId,
      },
    );

    if (result == null) {
      return StatusContainer(Status.fail, '获取云端数据失败');
    }

    if (result.code != 200) {
      return StatusContainer(Status.fail, '服务器异常');
    }

    try {
      final data = result.data as Map<String, dynamic>;
      final sharedTables = (data['shared_tables'] as List).map((item) {
        final container = item['container'] as Map<String, dynamic>;
        return CoursesContainer(
          id: container['id'] as String,
          type: CourseType.values
              .firstWhere((t) => t.name == container['type'] as String),
          term: container['term'] as String,
          sharerId: container['sharer_id'] as String,
          entries: (container['entries'] as List)
              .map((e) => CourseEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }).toList();

      return StatusContainer(Status.ok, sharedTables);
    } catch (e) {
      return StatusContainer(Status.fail, e.toString());
    }
  }

  /// 审核模式认证
  ///
  /// 用于 App 审核时的游客访问模式。
  /// 如果开启了审核模式，将使用预设账号登录并返回登录信息；
  /// 如果关闭审核模式，将返回404。
  ///
  /// 返回值: 包含登录结果的状态容器（成功则含 TGC，否则含错误信息）
  static Future<StatusContainer<dynamic>> reviewAuth() async {
    final response = await getBackendApiResponse(
      'GET',
      '/api/review_auth',
    );

    if (response == null) {
      return StatusContainer(Status.fail, '服务器请求失败');
    }

    if (response.code == 404) {
      return StatusContainer(Status.notAuthorized);
    }

    if (response.code != 200) {
      return StatusContainer(Status.fail, response.message);
    }

    return StatusContainer(Status.ok, response.data as Map<String, dynamic>);
  }

  /// 生成签名认证头
  ///
  /// 签名规则为：
  /// ```
  /// canonical_string = '{METHOD}\n{PATH}\n{QUERY_STRING}\n{APP_ID}\n{X-Timestamp}\n{X-Nonce}'
  /// signature = HMAC_SHA256(_hmacSecretKey, canonical_string)
  /// ```
  static Map<String, String> _generateAuthHeaders(
      String method, String path, String queryString) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final nonce = DateTime.now().microsecondsSinceEpoch.toString();
    final appId = 'swustmeow';

    final canonicalString =
        '$method\n$path\n$queryString\n$appId\n$timestamp\n$nonce';
    final key = utf8.encode(Config.swuststoreServerHMACSecretKey);
    final message = utf8.encode(canonicalString);
    final hmacDigest = Hmac(sha256, key).convert(message);
    final signature = hmacDigest.toString();

    return {
      'X-App-Id': appId,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
    };
  }

  /// AI 聊天流式请求
  ///
  /// 参数:
  ///   prompt: 用户输入的文本
  ///   useSearch: 是否使用搜索功能
  ///   searchQuery: 搜索关键词
  ///   systemMessage: 系统消息
  ///   history: 历史消息列表
  ///   onToken: 接收到新 token 时的回调
  ///   onError: 发生错误时的回调
  ///   onComplete: 完成时的回调
  static Future<void> streamChat({
    required String prompt,
    bool useSearch = false,
    String? searchQuery,
    String? systemMessage,
    List<AIChatMessage>? history,
    required Function(String token) onToken,
    Function(String error)? onError,
    VoidCallback? onComplete,
  }) async {
    Future<Map<String, dynamic>> parseErrorResponse(Response response) async {
      try {
        if (response.data == null) return {'msg': '未知错误'};

        final stream = response.data.stream as Stream<List<int>>;
        final buffer = await stream.fold<Uint8List>(
          Uint8List(0),
          (previous, element) => Uint8List.fromList([...previous, ...element]),
        );
        final text = utf8.decode(buffer);

        return jsonDecode(text) as Map<String, dynamic>;
      } catch (e) {
        return {'msg': '解析错误响应失败：$e'};
      }
    }

    try {
      final info = GlobalService.serverInfo;
      if (info == null) {
        onError?.call('无法连接到服务器');
        return;
      }

      final path = '/api/chat';
      final headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Accept': 'text/plain',
        ..._generateAuthHeaders('POST', path, ''),
      };

      // 构建历史消息列表
      final List<Map<String, String>> messages = [];

      // 添加历史消息
      if (history != null) {
        for (final msg in history) {
          messages.add({
            'role': msg.role.name, // 'user' 或 'assistant'
            'content': msg.content,
          });
        }
      }

      // 添加当前用户消息
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      final data = {
        'messages': messages, // 发送完整的消息历史
        'use_search': useSearch,
        if (searchQuery != null) 'search_query': searchQuery,
        if (systemMessage != null) 'system_message': systemMessage,
      };

      final dio = Dio(
        BaseOptions(
          responseType: ResponseType.stream,
          receiveTimeout: Duration(minutes: 2),
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      final response = await dio.post(
        '${info.pyServerUrl}$path',
        data: data,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 400) {
        final errorData = await parseErrorResponse(response);
        onError?.call(errorData['msg'] ?? '请求参数错误');
        return;
      }

      if (response.statusCode == 403) {
        onError?.call('认证失败，请重试');
        return;
      }

      if (response.statusCode == 429) {
        onError?.call('请求过于频繁，请稍后再试');
        return;
      }

      if (response.statusCode != 200) {
        onError?.call('服务器错误 (${response.statusCode})');
        return;
      }

      if (response.data == null) {
        onError?.call('服务器返回空响应');
        return;
      }

      final stream = response.data.stream as Stream<List<int>>;
      final utf8Decoder = Utf8Decoder();
      String buffer = '';

      try {
        await for (final chunk in stream) {
          final text = utf8Decoder.convert(chunk);
          buffer += text;

          // 处理缓冲区中的完整字符
          while (buffer.isNotEmpty) {
            if (buffer.startsWith('{')) {
              // 尝试解析JSON错误消息
              try {
                final errorData = jsonDecode(buffer) as Map<String, dynamic>;
                if (errorData['flag'] == false) {
                  onError?.call(errorData['msg'] ?? '未知错误');
                  return;
                }
                buffer = '';
              } catch (_) {
                // 如果不是完整的JSON，继续等待更多数据
                break;
              }
            } else {
              // 对于普通文本，逐字符发送
              onToken(buffer[0]);
              buffer = buffer.substring(1);
            }
          }
        }
        // 处理剩余的缓冲区内容
        if (buffer.isNotEmpty) {
          for (var i = 0; i < buffer.length; i++) {
            onToken(buffer[i]);
          }
        }
        onComplete?.call();
      } on TimeoutException {
        onError?.call('响应超时');
      } on WebSocketException {
        onError?.call('WebSocket 连接错误');
      } catch (e) {
        onError?.call('流处理错误：$e');
      }
    } on DioException catch (e) {
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '连接超时';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '发送超时';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '接收超时';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '服务器响应错误 (${e.response?.statusCode})';
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求已取消';
          break;
        default:
          errorMessage = '网络错误：${e.message}';
      }
      onError?.call(errorMessage);
    } catch (e, st) {
      debugPrint('AI 聊天请求失败：$e');
      debugPrintStack(stackTrace: st);
      onError?.call('请求失败：$e');
    }
  }
}
