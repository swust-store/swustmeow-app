import 'dart:io';

import 'package:dio/dio.dart';
import 'package:miaomiaoswust/entity/response_entity.dart';

import '../core/constants.dart';

Future<ResponseEntity<T>> getBackendApiResponse<T>(
    final String method, final String path,
    {final Dio? client,
    final Object? data,
    final Map<String, dynamic>? queryParameters,
    final Options? options}) async {
  final dio = client ?? Dio();
  final info = await Constants.serverInfo;
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
  return ResponseEntity.fromJson(resp.data as Map<String, dynamic>);
}
