import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:miaomiaoswust/views/settings/settings_about.dart';
import 'package:miaomiaoswust/views/settings/settings_appearance.dart';
import 'package:miaomiaoswust/views/settings/settings_logout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return PaddingContainer(
        decoration: BoxDecoration(color: context.theme.colorScheme.primaryForeground),
        ListView(
          children: joinPlaceholder(gap: 10, widgets: [
            const SettingsAppearance(),
            const SettingsAbout(),
            const SettingsLogOut(),
          ]),
        ));
  }
}
