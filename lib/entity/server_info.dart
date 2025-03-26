import 'package:hive/hive.dart';

part 'server_info.g.dart';

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

  @HiveField(0)
  final String pyServerUrl;

  @HiveField(1)
  final String libraryServerUrl;

  @HiveField(2)
  final String activitiesUrl;

  @HiveField(3)
  final String termDatesUrl;

  @HiveField(4)
  final String announcement;

  /// 格式：{'url': String, 'href': String}
  @HiveField(5)
  final List<Map<String, dynamic>> ads;

  /// 格式：{'name': String, 'qid': String, 'link': String}
  @HiveField(6)
  final List<Map<String, dynamic>> qun;

  /// 分类：{'heading': [], 'common': []}
  ///
  /// heading 格式：{'title': String, 'link': String, 'image': String}
  ///
  /// common 格式：{'title': String, 'link': String}
  @HiveField(7)
  final Map<String, List<dynamic>> news;

  @HiveField(8)
  final String changelogUrl;

  @HiveField(9)
  final Map<String, dynamic> agreements;

  @HiveField(10)
  final String? iosDistributionUrl;

  factory ServerInfo.fromJson(
    Map<String, dynamic> json, {
    required ServerInfo fallback,
  }) =>
      _$ServerInfoFromJson(json) ?? fallback;

  static ServerInfo? _$ServerInfoFromJson(Map<String, dynamic> json) {
    try {
      return ServerInfo(
        pyServerUrl: json['py_server_url'] as String,
        libraryServerUrl: json['library_server_url'] as String,
        activitiesUrl: json['activities_url'] as String,
        termDatesUrl: json['term_dates_url'] as String,
        announcement: json['announcement'] as String,
        ads: (json['ads'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
        qun: (json['qun'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
        news: (json['news'] as Map<String, dynamic>).map(
          (k, e) => MapEntry(k, e as List<dynamic>),
        ),
        changelogUrl: json['changelog_url'] as String,
        agreements: json['agreements'] as Map<String, dynamic>,
        iosDistributionUrl: json['ios_distribution_url'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
