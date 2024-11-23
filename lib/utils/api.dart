import 'package:dio/dio.dart';

import '../core/constants.dart';

Future<Response<dynamic>> getBackendApiResponse(
    final String method, final String path,
    {final Dio? client, final Options? options}) async {
  final dio = client ?? Dio();
  final info = await Constants.serverInfo;
  return await dio.request('${info.backendApiUrl}$path',
      options: options == null
          ? Options(method: method)
          : options.copyWith(method: method));
}
