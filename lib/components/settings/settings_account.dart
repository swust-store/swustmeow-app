import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/views/settings/settings_account_management_page.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/login_page.dart';

import '../../data/values.dart';
import '../../utils/widget.dart';
import '../utils/back_again_blocker.dart';

class SettingsAccount extends StatelessWidget {
  const SettingsAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return buildSettingTileGroup(
      context,
      '账号',
      [
        FTile(
          prefixIcon: FIcon(FAssets.icons.userRoundCog),
          title: const Text('账号管理'),
          subtitle: const Text('管理你的一站式服务、对分易等账号'),
          suffixIcon: FIcon(FAssets.icons.chevronRight),
          onPress: () => pushTo(context, '/settings/account_management',
              const SettingsAccountManagementPage()),
        ),
        FTile(
          prefixIcon: FIcon(
            FAssets.icons.logOut,
            color: Colors.red,
          ),
          title: const Text(
            '退出登录',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: Text(
            '退出所有账号',
            style: TextStyle(color: Colors.red.withValues(alpha: 0.7)),
          ),
          onPress: () => _showLogoutDialog(context),
        ),
        FTile(
          prefixIcon: FIcon(
            FAssets.icons.userRoundX,
            color: Colors.red,
          ),
          title: const Text(
            '注销账号',
            style: TextStyle(color: Colors.red),
          ),
          onPress: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(final BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => FDialog(
        direction: Axis.horizontal,
        title: const Text('确定要这样做吗？'),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: const Text('之后，你会返回到初始页面，并且需要重新登录所有的账号，所有的缓存都会被清空'),
        ),
        actions: [
          FButton(
            onPress: () => Navigator.of(context).pop(),
            label: Text(
              '算了吧',
              style: Values.dialogButtonTextStyle,
            ),
          ),
          FButton(
            onPress: () async => _logoutAll(context),
            label: Text('我确定', style: Values.dialogButtonTextStyle),
            style: FButtonStyle.outline,
          )
        ],
      ),
    );
  }

  Future<void> _logoutAll(BuildContext context) async {
    for (final service in GlobalService.services) {
      service.logout(notify: true);
    }

    if (context.mounted) {
      pushReplacement(
        context,
        '/login',
        const BackAgainBlocker(
          child: LoginPage(),
        ),
      );
    }
  }
}
