import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entity/course_entry.dart';
import '../entity/response_entity.dart';
import '../entity/server_info.dart';
import '../utils/status.dart';

Future<ResponseEntity<T>?> getBackendApiResponse<T>(
    final String method, final String path,
    {final Dio? client,
    final Object? data,
    final Map<String, dynamic>? queryParameters,
    final Options? options}) async {
  final dio = client ?? Dio();
  final prefs = await SharedPreferences.getInstance();
  final infoString = prefs.getString('serverInfo');

  if (infoString == null) {

    return ResponseEntity(code: 500, message: '无法从服务器拉取数据，请稍后再试~');
  }

  final infoJson = json.decode(infoString);
  final info = ServerInfo.fromJson(infoJson);

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

/// 根据登录凭证（TGC）获取普通课表
///
/// 若获取失败，返回包含错误信息字符串的状态容器；
/// 否则，返回包含课程表的状态容器。
Future<StatusContainer<dynamic>> getCourseTable(String tgc) async {
  final response = await getBackendApiResponse('GET', '/api/s/get_course_table',
      queryParameters: {'TGC': tgc});
  if (response == null || response.code != 200 || response.data == null) {
    return StatusContainer(
        response?.code == 401 ? Status.notAuthorized : Status.fail,
        response?.message);
  }

  final List<CourseEntry> entries = [];
  for (final Map<String, dynamic> entry in response.data!) {
    final entity = CourseEntry.fromJson(entry);
    entries.add(entity);
  }
  return StatusContainer(Status.ok, entries);
}
