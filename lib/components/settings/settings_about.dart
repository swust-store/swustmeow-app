import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../data/values.dart';
import '../../utils/router.dart';
import '../../utils/widget.dart';
import '../../views/settings_about_details_page.dart';

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
      ),
      FTile(
        prefixIcon: FIcon(FAssets.icons.book),
        title: const Text('用户协议与隐私政策'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
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
