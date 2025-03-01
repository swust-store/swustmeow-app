import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';

import '../../components/settings/settings_about.dart';
import '../../components/settings/settings_common.dart';
import '../../components/settings/settings_account.dart';
import '../../utils/widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.onRefresh,
  });

  final Function() onRefresh;

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage.gradient(
      headerPad: false,
      header: BaseHeader(
        showBackButton: false,
        title: Text(
          '设置',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.secondary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(MTheme.radius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 32.0),
            children: joinGap(
              gap: 10,
              axis: Axis.vertical,
              widgets: [
                // const SettingsAppearance(),
                SettingsCommon(onRefresh: widget.onRefresh),
                const SettingsAccount(),
                const SettingsAbout(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
