import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/views/settings_background_service.dart';

import '../../utils/common.dart';
import '../../utils/widget.dart';

class SettingsCommon extends StatefulWidget {
  const SettingsCommon({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsCommonState();
}

class _SettingsCommonState extends State<SettingsCommon> {
  @override
  Widget build(BuildContext context) {
    return buildSettingTileGroup(context, '通用', [
      FTile(
          prefixIcon: FIcon(FAssets.icons.trash2),
          title: const Text('清理缓存'),
          subtitle: const Text(
            '可用于刷新课表、校历等',
          ),
          onPress: () {
            clearCaches();
            showSuccessToast(context, '清理完成', alignment: Alignment.topCenter);
          }),
      FTile(
        prefixIcon: FIcon(FAssets.icons.settings2),
        title: const Text('后台服务'),
        subtitle: const Text('后台服务的相关设置，用于一些持续性任务'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
        onPress: () {
          pushTo(context, const SettingsBackgroundService());
        },
      )
    ]);
  }
}
