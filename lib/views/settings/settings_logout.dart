import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/values.dart';
import '../../utils/router.dart';
import '../../utils/widget.dart';
import '../main_page.dart';

class SettingsLogOut extends StatelessWidget {
  const SettingsLogOut({super.key});

  @override
  Widget build(BuildContext context) {
    return buildTileGroup(context, null, [
      FTile(
          prefixIcon: FIcon(FAssets.icons.logOut),
          title: const Text('退出登录'),
          suffixIcon: FIcon(FAssets.icons.chevronRight),
          onPress: () => _showLogOutDialog(context))
    ]);
  }

  void _showLogOutDialog(final BuildContext context) {
    showAdaptiveDialog(
        context: context,
        builder: (context) => FDialog(
                direction: Axis.horizontal,
                body: const Text('确定要退出登录吗？'),
                actions: [
                  FButton(
                      onPress: () => Navigator.of(context).pop(),
                      label: Text(
                        '算了',
                        style: Values.dialogButtonTextStyle,
                      ),
                      style: FButtonStyle.outline),
                  FButton(
                    onPress: () async => await _logOut(context),
                    label: Text('退出', style: Values.dialogButtonTextStyle),
                  )
                ]));
  }

  Future<void> _logOut(final BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);
    if (context.mounted) {
      pushTo(context, const MainPage());
    }
  }
}
