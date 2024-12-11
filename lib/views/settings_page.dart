import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/views/settings/settings_common.dart';

import '../components/padding_container.dart';
import '../utils/widget.dart';
import '../views/settings/settings_about.dart';
import '../views/settings/settings_appearance.dart';
import '../views/settings/settings_logout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return PaddingContainer(
        decoration: BoxDecoration(color: context.theme.colorScheme.background),
        child: ListView(
          children: joinPlaceholder(gap: 10, widgets: [
            const SettingsAppearance(),
            const SettingsAbout(),
            const SettingsCommon(),
            const SettingsLogOut(),
          ]),
        ));
  }
}
