import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/services/box_service.dart';

import '../data/values.dart';
import '../entity/run_mode.dart';
import '../utils/widget.dart';

class SettingsBackgroundService extends StatefulWidget {
  const SettingsBackgroundService({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsBackgroundServiceState();
}

class _SettingsBackgroundServiceState extends State<SettingsBackgroundService> {
  final FRadioSelectGroupController<RunMode> _runModeController =
      FRadioSelectGroupController();
  bool _enableNotification = true;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _runModeController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    final box = BoxService.commonBox;
    final runMode =
        (box.get('bgServiceRunMode') as RunMode?) ?? RunMode.foreground;
    _enableNotification = (box.get('bgServiceNotification') as bool?) ?? true;
    _runModeController.update(runMode, selected: true);
    _runModeController.addListener(() async {
      final value = _runModeController.value.first;
      await box.put('bgServiceRunMode', value);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    const maxLines = 100;

    return Transform.flip(
        flipX: Values.isFlipEnabled.value,
        flipY: Values.isFlipEnabled.value,
        child: FScaffold(
            contentPad: false,
            header: FHeader.nested(
              title: const Text(
                '后台服务',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              prefixActions: [
                FHeaderAction(
                    icon: FIcon(FAssets.icons.chevronLeft),
                    onPress: () => Navigator.of(context).pop())
              ],
            ).withBackground,
            content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView(padding: EdgeInsets.zero, children: [
                  buildSettingTileGroup(context, null, [
                    FSelectMenuTile<RunMode>(
                      title: const Text('运行模式'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListenableBuilder(
                              listenable: _runModeController,
                              builder: (context, _) => Text(
                                    '当前状态：${_getRunModeName()}',
                                    style: TextStyle(
                                        color: _currentRunMode ==
                                                RunMode.foreground
                                            ? Colors.pink
                                            : Colors.blue),
                                  )),
                          const SizedBox(height: 8.0),
                          Text(
                            '前台运行：只能保持应用在前台活跃状态，退出后可以继续运行直到应用后台被杀死，此模式下即使下方「显示通知」的选项被关闭，依旧会在最开始启动时发送一条通知\n\n后台运行：应用关闭或彻底退出（后台被杀死）仍然运行，更耗电，需要对本应用关闭电池优化',
                            maxLines: maxLines,
                          )
                        ],
                      ),
                      groupController: _runModeController,
                      menu: [
                        FSelectTile(
                            title: const Text('前台运行'),
                            value: RunMode.foreground),
                        FSelectTile(
                            title: const Text('后台运行'),
                            value: RunMode.background)
                      ],
                      autoHide: true,
                      details: Text(''),
                    ),
                    FTile(
                      title: const Text('显示通知'),
                      subtitle: const Text(
                        '开启一个无法关闭的通知，在运行时有助于随时查看状态，需要开启通知权限',
                        maxLines: maxLines,
                      ),
                      suffixIcon: FSwitch(
                        value: _enableNotification,
                        onChange: (value) async {
                          final service = FlutterBackgroundService();
                          service.invoke(
                              'changeNotificationStatus', {'value': value});
                          final box = BoxService.commonBox;
                          await box.put('bgServiceNotification', value);
                          setState(() => _enableNotification = value);
                        },
                      ),
                    )
                  ])
                ])).withBackground));
  }

  RunMode get _currentRunMode =>
      _runModeController.value.firstOrNull ?? RunMode.foreground;

  String _getRunModeName() => switch (_currentRunMode) {
        RunMode.foreground => '前台运行',
        RunMode.background => '后台运行'
      };
}
