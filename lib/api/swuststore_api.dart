import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/entity/course/course_entry.dart';
import 'package:miaomiaoswust/services/box_service.dart';

import '../entity/response_entity.dart';
import '../entity/server_info.dart';
import '../utils/status.dart';

Future<ResponseEntity<T>?> getBackendApiResponse<T>(
    final String method, final String path,
    {final Dio? client,
    final Object? data,
    final Map<String, dynamic>? queryParameters,
    final Options? options}) async {
  final dio = client ??
      Dio(BaseOptions(
          persistentConnection: false,
          sendTimeout: Duration(seconds: 5),
          receiveTimeout: Duration(seconds: 10)));

  final box = BoxService.commonBox;
  final info = box.get('serverInfo') as ServerInfo?;

  if (info == null) {
    return ResponseEntity(code: 500, message: '无法从服务器拉取数据，请稍后再试~');
  }

  final jsonHeaders = method == 'GET'
      ? null
      : {
          HttpHeaders.contentTypeHeader: 'application/json',
        };
  final resp = await dio.request('${info.backendApiUrl}$path',
      data: data,
      queryParameters: queryParameters,
      options: options == null
          ? Options(
              method: method, validateStatus: (_) => true, headers: jsonHeaders)
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
///
/// 若登录成功，返回包含 `TGC` 字符串的状态容器；
/// 否则，返回包含错误信息字符串的状态容器。
Future<StatusContainer<String>> loginToSOA(
    String username, String password) async {
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
///
/// 若获取成功，返回一个带有 [CourseEntry] 的列表的状态容器；
/// 否则，返回一个带有错误信息字符串的状态容器。
Future<StatusContainer<dynamic>> getExperimentCourseEntries(
    String tgc, String term) async {
  var fixedTerm = term;
  final shouldFix = int.tryParse(fixedTerm.characters.last) == null;
  if (shouldFix) {
    final [s, e, i] = fixedTerm.split('-');
    fixedTerm = '$s-$e-${i == '上' ? '1' : '2'}';
  }

  final response = await getBackendApiResponse(
      'GET', '/api/s/get_experiment_course_table',
      queryParameters: {'TGC': tgc, 'term': fixedTerm});

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
