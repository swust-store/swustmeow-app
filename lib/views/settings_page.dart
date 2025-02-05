import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../components/padding_container.dart';
import '../components/settings/settings_about.dart';
import '../components/settings/settings_appearance.dart';
import '../components/settings/settings_common.dart';
import '../components/settings/settings_account.dart';
import '../utils/widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return PaddingContainer(
        child: ListView(
      children: joinGap(gap: 10, axis: Axis.vertical, widgets: [
        // const SettingsAppearance(),
        const SettingsCommon(),
        const SettingsAbout(),
        const SettingsAccount(),
      ]),
    )).withBackground;
  }
}
