import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_info.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class ServerInfo {
  const ServerInfo({
    required this.backendApiUrl,
    required this.activitiesUrl,
    required this.termDatesUrl,
    required this.announcement,
    required this.ads,
    required this.qun,
  });

  @JsonKey(name: 'backend_api_url')
  @HiveField(0)
  final String backendApiUrl;

  @JsonKey(name: 'activities_url')
  @HiveField(1)
  final String activitiesUrl;

  @JsonKey(name: 'term_dates_url')
  @HiveField(2)
  final String termDatesUrl;

  @HiveField(3)
  final String announcement;

  /// 格式：{'url': String, 'href': String}
  @HiveField(4)
  final List<Map<String, String>> ads;

  /// 格式：{'name': String, 'qid': String, 'link': String}
  @HiveField(5)
  final List<Map<String, String>> qun;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
