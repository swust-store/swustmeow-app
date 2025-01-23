import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:miaomiaoswust/entity/server_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entity/response_entity.dart';

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
