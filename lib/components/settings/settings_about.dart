import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/services/version_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/views/settings/settings_feature_suggestion_page.dart';

import '../../data/values.dart';
import '../../utils/router.dart';
import '../../views/settings/settings_about_details_page.dart';
import '../../views/settings/settings_changelog_page.dart';
import '../simple_setting_item.dart';
import '../simple_settings_group.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({super.key});

  @override
  State<SettingsAbout> createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  int _versionTapCount = 0;
  final int _requiredTaps = 10;

  void _handleVersionTap() {
    setState(() {
      _versionTapCount++;
      if (_versionTapCount >= _requiredTaps) {
        _versionTapCount = 0;
        showInfoToast('开发者模式已启用...？', seconds: 10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailsStyle = TextStyle(fontSize: 14, color: Colors.black);

    return ValueListenableBuilder(
      valueListenable: ValueService.hasUpdate,
      builder: (context, hasUpdate, child) {
        return SimpleSettingsGroup(
          title: '关于',
          children: [
            SimpleSettingItem(
              title: '建议反馈',
              icon: FontAwesomeIcons.solidComments,
              onPress: () => pushTo(context, '/settings/suggestions',
                  const SettingsFeatureSuggestionPage()),
            ),
            SimpleSettingItem(
              title: '当前版本',
              icon: FontAwesomeIcons.tags,
              suffix: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'v${Values.version}-${Values.buildVersion}',
                  style: detailsStyle,
                ),
              ),
              onPress: _handleVersionTap,
            ),
            SimpleSettingItem(
              title: !hasUpdate ? '检查更新' : '有新版本！',
              icon: FontAwesomeIcons.circleArrowUp,
              hasSuffix: false,
              color: !hasUpdate ? Colors.black : Colors.green,
              onPress: () => VersionService.checkUpdate(context, force: true),
            ),
            SimpleSettingItem(
              title: '更新日志',
              icon: FontAwesomeIcons.boxArchive,
              onPress: () => pushTo(context, '/settings/changelog',
                  const SettingsChangelogPage()),
            ),
            SimpleSettingItem(
              title: '关于',
              icon: FontAwesomeIcons.circleInfo,
              onPress: () => pushTo(
                  context, '/settings/about', const SettingsAboutDetailsPage()),
            ),
          ],
        );
      },
    );
  }
}
