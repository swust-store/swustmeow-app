import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:swustmeow/utils/status.dart';

import '../services/global_service.dart';

class LibraryApiService {
  final Dio _dio = Dio();

  static const String _appId = 'swustmeow';
  static const String _apiSecret =
      'REDACTED_LIBRARY_SERVER_SECRET';

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
    final key = utf8.encode(_apiSecret);
    final message = utf8.encode(canonicalString);
    final hmacDigest = Hmac(sha256, key).convert(message);
    final signature = hmacDigest.toString();
    return {
      'X-App-Id': _appId,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
    };
  }

  /// 统一处理 API 返回的 JSON 数据
  StatusContainer<dynamic> _handleResponse(Response response) {
    if (response.statusCode == 401) {
      return StatusContainer(Status.notAuthorized, '未授权');
    }

    if (response.statusCode != 200) {
      return StatusContainer(Status.fail, '错误代码 ${response.statusCode}');
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
  /// 调用 GET {baseUrl}/api/library/directories
  ///
  /// 返回 JSON 格式：
  /// {
  ///   'flag': true,
  ///   'msg': '',
  ///   'data': {
  ///     'directories': ['目录1', '目录2', ...]
  ///   }
  /// }
  Future<StatusContainer<dynamic>> getDirectories() async {
    final String path = '/api/library/directories';
    final String queryString = '';
    final headers = _generateHeaders('GET', path, queryString);
    final Response response = await _dio.get(
      _getUrl(path),
      options: Options(headers: headers),
    );
    return _handleResponse(response);
  }

  /// 获取指定目录下的所有文件
  ///
  /// 需传入目录名，调用 POST {baseUrl}/api/library/list
  Future<StatusContainer<dynamic>> listFiles(String directory) async {
    final String path = '/api/library/list';
    final headers = _generateHeaders('POST', path, '');
    final Response response = await _dio.post(
      _getUrl(path),
      data: {'directory': directory},
      options: Options(headers: headers),
    );
    return _handleResponse(response);
  }

  /// 下载指定目录下的文件
  ///
  /// 需传入目录与文件名，调用 POST {baseUrl}/api/library/download
  Future<StatusContainer<dynamic>> downloadFile(
      String directory, String filename) async {
    final String path = '/api/library/download';
    final headers = _generateHeaders('POST', path, '');
    final Response response = await _dio.post(
      _getUrl(path),
      data: {'directory': directory, 'filename': filename},
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
      ),
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
  }

  /// 搜索文件
  ///
  /// 根据搜索关键词（searchTerm）搜索所有目录中的文件名，
  /// 后端会根据目录分类返回匹配结果，
  ///
  /// 调用 POST {baseUrl}/api/library/search，
  /// 返回 JSON 格式：
  /// {
  ///   "flag": true,
  ///   "msg": "",
  ///   "data": {
  ///     "results": {
  ///       "目录1": ["文件名1", "文件名2", ...],
  ///       "目录2": ["文件名3", "文件名4", ...],
  ///       ...
  ///     }
  ///   }
  /// }
  Future<StatusContainer<dynamic>> searchFiles(String query) async {
    final String path = '/api/library/search';
    final Map<String, String> headers = _generateHeaders('POST', path, '');
    final Response response = await _dio.post(
      _getUrl(path),
      data: {'query': query},
      options: Options(headers: headers),
    );
    return _handleResponse(response);
  }
}
