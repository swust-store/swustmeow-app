import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_info.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class ServerInfo {
  const ServerInfo({required this.backendApiUrl});

  @HiveField(0)
  final String backendApiUrl;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
