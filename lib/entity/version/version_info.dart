import 'package:hive/hive.dart';
import 'package:swustmeow/entity/version/version.dart';
import 'package:swustmeow/entity/version/version_push_type.dart';

part 'version_info.g.dart';

@HiveType(typeId: 25)
class VersionInfo {
  const VersionInfo({
    required this.version,
    required this.releaseDate,
    required this.pushType,
    required this.distributionUrl,
    required this.changes,
  });

  @HiveField(0)
  final Version version;
  @HiveField(1)
  final DateTime releaseDate;
  @HiveField(2)
  final VersionPushType pushType;
  @HiveField(3)
  final String distributionUrl;
  @HiveField(4)
  final List<String> changes;
}
