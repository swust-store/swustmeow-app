import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miaomiaoswust/core/values.dart';

part 'server_info.g.dart';

@JsonSerializable()
class ServerInfo {
  const ServerInfo({required this.backendApiUrl});

  final String backendApiUrl;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);

  static Future<ServerInfo> fetch() async {
    final dio = Dio();
    final response = await dio.get(Values.fetchInfoUrl);
    return ServerInfo.fromJson(response.data as Map<String, dynamic>);
  }
}
