import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/simple_setting_item.dart';
import 'package:swustmeow/components/simple_settings_group.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/settings/settings_background_service.dart';

import '../../utils/common.dart';

class SettingsCommon extends StatelessWidget {
  final Function() onRefresh;

  const SettingsCommon({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SimpleSettingsGroup(
      title: '通用',
      children: [
        SimpleSettingItem(
          title: '清理缓存',
          subtitle: '可用于刷新课表、校历等',
          icon: FontAwesomeIcons.trash,
          hasSuffix: false,
          onPress: () {
            clearCaches();
            onRefresh();
            showSuccessToast('清理完成', alignment: Alignment.topCenter);
          },
        ),
        SimpleSettingItem(
          title: '后台服务',
          subtitle: '后台服务的相关设置，用于一些持续性任务',
          icon: FontAwesomeIcons.gear,
          onPress: () => pushTo(context, '/settings/background_service',
              const SettingsBackgroundService()),
        ),
      ],
    );
  }
}
