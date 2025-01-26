import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/services/box_service.dart';

import '../../data/values.dart';
import '../../utils/widget.dart';

class SettingsAppearance extends StatefulWidget {
  const SettingsAppearance({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsAppearanceState();
}

class _SettingsAppearanceState extends State<SettingsAppearance> {
  FRadioSelectGroupController<ThemeMode> themeModeController =
      FRadioSelectGroupController(
          value: ThemeMode.values
              .where((m) => m.name == (Values.themeMode?.name ?? 'system'))
              .first);
  bool isFirstInitialize = true;
  final List<ThemeMode> modesQueue = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    themeModeController.dispose();
    isFirstInitialize = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSettingTileGroup(context, '外观', [
      FSelectMenuTile(
          groupController: themeModeController,
          autoHide: true,
          prefixIcon: FIcon(FAssets.icons.sunMoon),
          title: const Text('主题模式'),
          subtitle: const Text(
            '切换需重启 APP 生效',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          details: ListenableBuilder(
              listenable: themeModeController,
              builder: (context, _) => _onThemeModeChange(context)),
          menu: [
            FSelectTile(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              subtitle: const Text('自动根据系统切换'),
            ),
            FSelectTile(title: const Text('明亮模式'), value: ThemeMode.light),
            FSelectTile(title: const Text('暗黑模式'), value: ThemeMode.dark),
          ]),
    ]);
  }

  Widget _onThemeModeChange(final BuildContext context) {
    final result = themeModeController.values.firstOrNull ?? ThemeMode.system;
    // 不知道为什么一初始化就会自动执行两遍
    // 只好用这种傻瓜方式
    if (isFirstInitialize) {
      modesQueue.add(result);
      if (modesQueue.length >= 2) {
        _changeThemeMode(result);
        modesQueue.clear();
        isFirstInitialize = false;
      }
    } else {
      _changeThemeMode(result);
    }
    return Text(switch (result) {
      ThemeMode.system => '跟随系统',
      ThemeMode.light => '明亮模式',
      ThemeMode.dark => '暗黑模式',
    });
  }

  Future<void> _changeThemeMode(final ThemeMode mode) async {
    final box = BoxService.commonBox;
    await box.put('themeMode', mode.name);
    setState(() => Values.themeMode = mode);
  }
}
