import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/components/version_dialog.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/version/version.dart';
import 'package:swustmeow/services/boxes/version_box.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/common.dart';

import '../entity/version/version_info.dart';
import '../entity/version/version_push_type.dart';

class VersionService {
  static Future<List<VersionInfo>> fetchVersionInfoList() async {
    final info = GlobalService.serverInfo;
    if (info == null) return [];

    final changelogUrl = info.changelogUrl;
    final dio = Dio();
    final response = await dio.get(changelogUrl);
    final data = response.data as Map<String, dynamic>;

    final result = <VersionInfo>[];
    for (final abc in data.keys) {
      final version = Version.parse(abc);
      final json = data[abc]!;
      final releaseDate = DateTime.parse(json['release_date']);
      final pushType = VersionPushType.values
          .singleWhere((v) => v.name == json['push_type']);
      final distributionUrl = json['distribution_url'];
      List<String> changes = (json['changes'] as List<dynamic>).cast();
      result.add(
        VersionInfo(
          version: version,
          releaseDate: releaseDate,
          pushType: pushType,
          distributionUrl: distributionUrl,
          changes: changes,
        ),
      );
    }
    return result;
  }

  static Future<VersionInfo?> getUpdateVersion({bool force = false}) async {
    final currentVersion = Version.parse(Values.version);
    final cached = ValueService.versionInfoList;
    final newVersions = !force
        ? (cached ?? await fetchVersionInfoList())
        : await fetchVersionInfoList();
    ValueService.versionInfoList = newVersions;

    if (newVersions.isEmpty) return null;

    newVersions.sort((a, b) => a.version.compareTo(b.version));

    VersionInfo? latestMajor;
    VersionInfo? lastMinor;

    for (var version in newVersions) {
      if (version.version <= currentVersion) continue;
      if (version.pushType == VersionPushType.major) {
        latestMajor = version;
      } else {
        lastMinor = version;
      }
    }

    return latestMajor ?? lastMinor;
  }

  static Future<void> checkUpdate(
    BuildContext context, {
    bool force = false,
  }) async {
    if (Values.showcaseMode) {
      if (force) {
        showInfoToast(context, '当前是最新版本！');
      }
      return;
    }

    final latest = await VersionService.getUpdateVersion(force: force);
    debugPrint(
        'latest = ${latest?.version}, type = ${latest?.pushType} | dismissed = ${latest == null ? null : _isDismissed(latest)}');

    if (latest != null) {
      ValueService.hasUpdate.value = true;
      ValueService.latestVersion = latest;
    }

    if (latest == null || (_isDismissed(latest) && !force)) {
      if (force) {
        if (!context.mounted) return;
        showInfoToast(context, '当前是最新版本！');
      }
      return;
    }

    if (!context.mounted) return;
    final flag = await VersionService.showVersionUpdateDialog(context, latest);
    if (!flag) {
      if (latest.pushType == VersionPushType.minor) {
        await _dismiss(latest);
      }
    }
  }

  static bool _isDismissed(VersionInfo info) {
    final version = info.version;
    List<VersionInfo>? dismissedVersions =
        (VersionBox.get('dismissedVersions') as List<dynamic>?)?.cast() ?? [];
    return (dismissedVersions.where((c) => c.version == version)).isNotEmpty;
  }

  static Future<void> _dismiss(VersionInfo info) async {
    List<VersionInfo>? dismissedVersions =
        (VersionBox.get('dismissedVersions') as List<dynamic>?)?.cast() ?? [];
    dismissedVersions.add(info);
    await VersionBox.put('dismissedVersions', dismissedVersions);
  }

  static Future<bool> showVersionUpdateDialog(
      BuildContext context, VersionInfo info) async {
    return await showAdaptiveDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          builder: (context) => VersionDialog(info: info),
        ) ??
        false;
  }
}
