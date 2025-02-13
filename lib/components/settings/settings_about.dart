import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/services/version_service.dart';

import '../../data/values.dart';
import '../../utils/router.dart';
import '../../utils/widget.dart';
import '../../views/settings/settings_about_details_page.dart';

class SettingsAbout extends StatelessWidget {
  const SettingsAbout({super.key});

  @override
  Widget build(BuildContext context) {
    const detailsStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

    return buildSettingTileGroup(context, '关于', [
      FTile(
        prefixIcon: FIcon(FAssets.icons.layoutGrid),
        title: const Text('当前版本'),
        suffixIcon: Text(
          'v${Values.version}',
          style: detailsStyle,
        ),
      ),
      FTile(
        prefixIcon: FIcon(FAssets.icons.circleArrowUp),
        title: const Text('检查更新'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
        onPress: () => VersionService.checkUpdate(context, force: true),
      ),
      FTile(
        prefixIcon: FIcon(FAssets.icons.info),
        title: const Text('关于'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
        onPress: () => pushTo(context, const SettingsAboutDetailsPage()),
      )
    ]);
  }
}
