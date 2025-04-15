import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/config.dart';
import 'package:uuid/uuid.dart';
import 'package:swustmeow/utils/status.dart';

import '../entity/library/directory_info.dart';
import '../entity/library/file_info.dart';
import '../services/global_service.dart';

class LibraryApiService {
  final Dio _dio = Dio();

  static const String _appId = 'swustmeow';

  /// 初始化 Dio 配置
  Future<void> init() async {
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (compatible; SWUSTStoreApp)',
      'Accept-Language': 'zh-CN,zh;q=0.8',
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    // 如果需要忽略状态码检查可设置 validateStatus
    _dio.options.validateStatus = (status) => true;
  }

  String _getUrl(String path) {
    final info = GlobalService.serverInfo;
    return '${info!.libraryServerUrl}$path';
  }

  /// 生成签名认证头
  ///
  /// 签名规则为：
  /// ```
  /// canonical_string = '{METHOD}\n{PATH}\n{QUERY_STRING}\n{APP_ID}\n{X-Timestamp}\n{X-Nonce}'
  /// signature = HMAC_SHA256(_apiSecret, canonical_string)
  /// ```
  Map<String, String> _generateHeaders(
      String method, String path, String queryString) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final nonce = Uuid().v4();
    final canonicalString =
        '$method\n$path\n$queryString\n$_appId\n$timestamp\n$nonce';
    final key = utf8.encode(Config.libraryServerSecret);
    final message = utf8.encode(canonicalString);
    final hmacDigest = Hmac(sha256, key).convert(message);
    final signature = hmacDigest.toString();
    return {
      'X-App-Id': _appId,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
      'X-API-Version': 'v2',
    };
  }

  /// 统一处理 API 返回的 JSON 数据
  StatusContainer<dynamic> _handleResponse(Response response) {
    if (response.statusCode == 401) {
      return StatusContainer(Status.notAuthorized, '未授权');
    }

    if (response.statusCode != 200) {
      try {
        final json = response.data as Map<String, dynamic>;
        final String? msg = json['msg'];
        return StatusContainer(Status.fail, msg ?? '未知错误');
      } catch (_) {
        return StatusContainer(Status.fail, '错误代码 ${response.statusCode}');
      }
    }

    try {
      final Map<String, dynamic> json =
          response.data is String ? jsonDecode(response.data) : response.data;
      final bool flag = json['flag'] == true;
      final String? msg = json['msg'];
      final Map<String, dynamic>? data = json['data'];
      if (!flag || data == null) {
        return StatusContainer(Status.fail, msg ?? '未知错误');
      }
      return StatusContainer(Status.ok, data);
    } catch (e) {
      return StatusContainer(Status.fail, '解析响应失败');
    }
  }

  /// 获取所有目录
  ///
  /// 支持分页
  /// 返回 JSON 格式：
  /// {
  ///   'flag': true,
  ///   'msg': '',
  ///   'data': {
  ///     'directories': [
  ///       {
  ///         'name': '目录1',
  ///         'file_count': 10
  ///       },
  ///       ...
  ///     ],
  ///     'total': 100,
  ///     'page': 1,
  ///     'page_size': 20,
  ///     'total_pages': 5
  ///   }
  /// }
  Future<StatusContainer<dynamic>> getDirectories(
      {int page = 1, int pageSize = 20}) async {
    try {
      final String path = '/api/v2/library/directories';
      final String queryString = 'page=$page&page_size=$pageSize';
      final headers = _generateHeaders('GET', path, queryString);
      final Response response = await _dio.get(
        _getUrl('$path?$queryString'),
        options: Options(headers: headers),
      );

      final result = _handleResponse(response);
      if (result.status != Status.ok) {
        return StatusContainer(result.status, result.value);
      }

      try {
        final Map<String, dynamic> data = result.value as Map<String, dynamic>;
        final List<dynamic> dirList = data['directories'];
        final directories = dirList
            .map((dir) => DirectoryInfo(
                  name: dir['name'],
                  fileCount: dir['file_count'],
                ))
            .toList();

        // 返回分页信息
        return StatusContainer(Status.ok, {
          'directories': directories,
          'total': data['total'],
          'page': data['page'],
          'page_size': data['page_size'],
          'total_pages': data['total_pages'],
        });
      } catch (e) {
        return StatusContainer(Status.fail, '解析目录数据失败');
      }
    } on Exception catch (e, st) {
      debugPrint('获取资料库所有目录失败：$e');
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '请求错误');
    }
  }

  /// 获取指定目录下的所有文件
  ///
  /// 支持分页
  /// 返回 JSON 格式：
  /// {
  ///   'flag': true,
  ///   'msg': '',
  ///   'data': {
  ///     'files': [
  ///       {
  ///         'name': '文件名1',
  ///         'size': 1024,
  ///         'uuid': '550e8400-e29b-41d4-a716-446655440000'
  ///       },
  ///       ...
  ///     ],
  ///     'total': 100,
  ///     'page': 1,
  ///     'page_size': 20,
  ///     'total_pages': 5
  ///   }
  /// }
  Future<StatusContainer<dynamic>> listFiles(
    String directory, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final String path = '/api/v2/library/list';
      final headers = _generateHeaders('POST', path, '');
      final Response response = await _dio.post(
        _getUrl(path),
        data: {
          'directory': directory,
          'page': page,
          'page_size': pageSize,
        },
        options: Options(headers: headers),
      );

      final result = _handleResponse(response);
      if (result.status != Status.ok) {
        return StatusContainer(result.status, result.value);
      }

      try {
        final Map<String, dynamic> data = result.value as Map<String, dynamic>;
        final List<dynamic> fileList = data['files'];
        final files = fileList
            .map((file) => FileInfo(
                  name: file['name'],
                  size: file['size'],
                  uuid: file['uuid'],
                ))
            .toList();

        // 返回分页信息
        return StatusContainer(Status.ok, {
          'files': files,
          'total': data['total'],
          'page': data['page'],
          'page_size': data['page_size'],
          'total_pages': data['total_pages'],
        });
      } catch (e) {
        return StatusContainer(Status.fail, '解析文件列表失败');
      }
    } on Exception catch (e, st) {
      debugPrint('获取资料库指定目录下的所有文件失败：$e');
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '请求错误');
    }
  }

  /// 下载指定文件
  ///
  /// 需传入文件的 UUID
  /// [onProgress] 回调函数用于报告下载进度，参数为已下载字节数和总字节数
  Future<StatusContainer<dynamic>> downloadFile(
    String uuid, {
    void Function(int count, int? total)? onProgress,
  }) async {
    try {
      final String path = '/api/v2/library/download';
      final headers = _generateHeaders('POST', path, '');
      final Response response = await _dio.post(
        _getUrl(path),
        data: {'uuid': uuid},
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: onProgress,
      );

      final contentType = response.headers.value('content-type');
      if (contentType != null && contentType.contains('application/json')) {
        final String jsonStr = utf8.decode(response.data);
        final Map<String, dynamic> jsonResponse = jsonDecode(jsonStr);
        final bool flag = jsonResponse['flag'] == true;
        final String? msg = jsonResponse['msg'];
        if (!flag) {
          return StatusContainer(Status.fail, msg ?? '未知错误');
        }
        return StatusContainer(Status.fail, '无法解析内容');
      } else {
        return StatusContainer(Status.ok, response.data);
      }
    } on Exception catch (e, st) {
      debugPrint('资料库下载指定文件失败：$e');
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '请求错误');
    }
  }

  /// 搜索文件
  ///
  /// 返回 JSON 格式：
  /// {
  ///   'flag': true,
  ///   'msg': '',
  ///   'data': {
  ///     'results': {
  ///       '目录1': [
  ///         {
  ///           'name': '文件名1',
  ///           'size': 1024,
  ///           'uuid': '550e8400-e29b-41d4-a716-446655440000'
  ///         },
  ///         ...
  ///       ],
  ///       ...
  ///     }
  ///   }
  /// }
  Future<StatusContainer<dynamic>> searchFiles(String query) async {
    try {
      final String path = '/api/v2/library/search';
      final headers = _generateHeaders('POST', path, '');
      final Response response = await _dio.post(
        _getUrl(path),
        data: {'query': query},
        options: Options(headers: headers),
      );

      final result = _handleResponse(response);
      if (result.status != Status.ok) {
        return StatusContainer(result.status, result.value);
      }

      try {
        final Map<String, dynamic> results = (result.value as Map)['results'];
        final searchResults = results.map((dir, files) => MapEntry(
              dir,
              (files as List)
                  .map((file) => FileInfo(
                        name: file['name'],
                        size: file['size'],
                        uuid: file['uuid'],
                      ))
                  .toList(),
            ));
        return StatusContainer(Status.ok, searchResults);
      } catch (e) {
        return StatusContainer(Status.fail, '解析搜索结果失败');
      }
    } on Exception catch (e, st) {
      debugPrint('资料库搜索文件失败：$e');
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '请求错误');
    }
  }

  /// 上传文件
  ///
  /// [file] 要上传的文件
  /// [directory] 要上传到的目录
  /// [onProgress] 回调函数用于报告上传进度，参数为已上传字节数和总字节数
  Future<StatusContainer<dynamic>> uploadFile(
    String filePath,
    String directory, {
    void Function(int count, int total)? onProgress,
  }) async {
    try {
      final String path = '/api/v2/library/upload';
      final headers = _generateHeaders('POST', path, '');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'directory': directory,
      });

      final Response response = await _dio.post(
        _getUrl(path),
        data: formData,
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'multipart/form-data',
          },
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => true,
        ),
        onSendProgress: onProgress,
      );

      if (response.statusCode == 302) {
        final String? redirectUrl = response.headers.value('location');
        if (redirectUrl != null) {
          final newFormData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              filePath,
              filename: filePath.split('/').last,
            ),
            'directory': directory,
          });

          final redirectResponse = await _dio.post(
            redirectUrl,
            data: newFormData,
            options: Options(
              headers: headers,
              followRedirects: true,
              maxRedirects: 5,
            ),
            onSendProgress: onProgress,
          );
          return _handleResponse(redirectResponse);
        }
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return StatusContainer(Status.fail, '上传超时');
      }
      debugPrint('资料库上传文件失败：$e');
      debugPrintStack(stackTrace: e.stackTrace);
      return StatusContainer(Status.fail, '上传失败');
    } on Exception catch (e, st) {
      debugPrint('资料库上传文件失败：$e');
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '上传失败');
    }
  }

  /// 删除指定文件
  ///
  /// 需传入文件的 UUID
  /// 返回 JSON 格式：
  /// {
  ///   'flag': true,
  ///   'msg': '文件删除成功',
  ///   'data': {}
  /// }
  Future<StatusContainer<dynamic>> deleteFile(String uuid) async {
    try {
      final String path = '/api/v2/library/delete';
      final headers = _generateHeaders('POST', path, '');
      final Response response = await _dio.post(
        _getUrl(path),
        data: {'uuid': uuid},
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on Exception catch (e, st) {
      debugPrint('资料库删除文件失败：$e');
      debugPrintStack(stackTrace: st);
      return StatusContainer(Status.fail, '请求错误');
    }
  }
}
