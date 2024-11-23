import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miaomiaoswust/core/constants.dart';

part 'server_info.g.dart';

@JsonSerializable()
class ServerInfo {
  const ServerInfo({required this.backendApiUrl});

  final String backendApiUrl;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);

  static Future<ServerInfo> fetch() async {
    final dio = Dio();
    final response = await dio.get(Constants.fetchInfoUrl);
    final Map<String, dynamic> data = jsonDecode(response.data);
    return ServerInfo.fromJson(data);
  }
}
