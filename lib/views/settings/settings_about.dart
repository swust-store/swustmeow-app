import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../utils/router.dart';
import '../../utils/widget.dart';
import 'about/settings_about_details_page.dart';

class SettingsAbout extends StatelessWidget {
  const SettingsAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return buildTileGroup(context, '关于', [
      FTile(
        prefixIcon: FIcon(FAssets.icons.info),
        title: const Text('关于喵喵西科'),
        suffixIcon: FIcon(FAssets.icons.chevronRight),
        onPress: () => pushTo(context, const SettingsAboutDetailsPage()),
      )
    ]);
  }
}
