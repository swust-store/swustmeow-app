import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_info.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class ServerInfo {
  const ServerInfo({
    required this.pyServerUrl,
    required this.libraryServerUrl,
    required this.activitiesUrl,
    required this.termDatesUrl,
    required this.announcement,
    required this.ads,
    required this.qun,
    required this.news,
    required this.changelogUrl,
    required this.agreements,
    this.iosDistributionUrl,
  });

  @JsonKey(name: 'py_server_url')
  @HiveField(0)
  final String pyServerUrl;

  @JsonKey(name: 'library_server_url')
  @HiveField(1)
  final String libraryServerUrl;

  @JsonKey(name: 'activities_url')
  @HiveField(2)
  final String activitiesUrl;

  @JsonKey(name: 'term_dates_url')
  @HiveField(3)
  final String termDatesUrl;

  @HiveField(4)
  final String announcement;

  /// 格式：{'url': String, 'href': String}
  @HiveField(5)
  final List<Map<String, String>> ads;

  /// 格式：{'name': String, 'qid': String, 'link': String}
  @HiveField(6)
  final List<Map<String, String>> qun;

  /// 分类：{'heading': [], 'common': []}
  ///
  /// heading 格式：{'title': String, 'link': String, 'image': String}
  ///
  /// common 格式：{'title': String, 'link': String}
  @HiveField(7)
  final Map<String, List<dynamic>> news;

  @JsonKey(name: 'changelog_url')
  @HiveField(8)
  final String changelogUrl;

  @HiveField(9)
  final Map<String, dynamic> agreements;

  @JsonKey(name: 'ios_distribution_url')
  @HiveField(10)
  final String? iosDistributionUrl;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
