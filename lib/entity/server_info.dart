import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_info.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class ServerInfo {
  const ServerInfo(
      {required this.backendApiUrl,
      required this.activitiesUrl,
      required this.termDatesUrl});

  @HiveField(0)
  final String backendApiUrl;

  @HiveField(1)
  final String activitiesUrl;

  @HiveField(2)
  final String termDatesUrl;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
