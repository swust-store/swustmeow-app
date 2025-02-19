import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/services/version_service.dart';

import '../../data/values.dart';
import '../../utils/router.dart';
import '../../utils/widget.dart';
import '../../views/settings/settings_about_details_page.dart';
import '../../views/settings/settings_changelog_page.dart';

class SettingsAbout extends StatelessWidget {
  const SettingsAbout({super.key});

  @override
  Widget build(BuildContext context) {
    const detailsStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

    return ValueListenableBuilder(
      valueListenable: ValueService.hasUpdate,
      builder: (context, hasUpdate, child) {
        return buildSettingTileGroup(
          context,
          '关于',
          [
            FTile(
              prefixIcon: FIcon(FAssets.icons.layoutGrid),
              title: const Text('当前版本'),
              suffixIcon: Text(
                'v${Values.version}',
                style: detailsStyle,
              ),
            ),
            FTile(
              prefixIcon: FIcon(
                FAssets.icons.circleArrowUp,
                color: !hasUpdate ? Colors.black : Colors.green,
              ),
              title: Text(
                !hasUpdate ? '检查更新' : '有新版本！',
                style: TextStyle(
                  color: !hasUpdate ? Colors.black : Colors.green,
                ),
              ),
              suffixIcon: FIcon(
                FAssets.icons.chevronRight,
                color: !hasUpdate ? Colors.black : Colors.green,
              ),
              onPress: () => VersionService.checkUpdate(context, force: true),
            ),
            FTile(
              prefixIcon: FIcon(FAssets.icons.fileClock),
              title: const Text('更新日志'),
              suffixIcon: FIcon(FAssets.icons.chevronRight),
              onPress: () => pushTo(context, const SettingsChangelogPage()),
            ),
            FTile(
              prefixIcon: FIcon(FAssets.icons.info),
              title: const Text('关于'),
              suffixIcon: FIcon(FAssets.icons.chevronRight),
              onPress: () => pushTo(context, const SettingsAboutDetailsPage()),
            )
          ],
        );
      },
    );
  }
}
