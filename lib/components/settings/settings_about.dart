import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/services/version_service.dart';
import 'package:swustmeow/views/settings/settings_agreements_page.dart';

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
        prefixIcon: FaIcon(FontAwesomeIcons.codeCompare),
        title: const Text('当前版本'),
        suffixIcon: Text(
          'v${Values.version}',
          style: detailsStyle,
        ),
      ),
      FTile(
        prefixIcon: FaIcon(FontAwesomeIcons.solidCircleUp),
        title: const Text('检查更新'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
        onPress: () => VersionService.checkUpdate(context, force: true),
      ),
      FTile(
        prefixIcon: FaIcon(FontAwesomeIcons.book),
        title: const Text('用户协议与隐私政策'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
        onPress: () => pushTo(context, const SettingsAgreementsPage()),
      ),
      FTile(
        prefixIcon: FaIcon(FontAwesomeIcons.circleInfo),
        title: const Text('关于'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
        onPress: () => pushTo(context, const SettingsAboutDetailsPage()),
      )
    ]);
  }
}
