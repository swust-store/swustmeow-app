import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../services/boxes/duifene_box.dart';
import '../../services/global_service.dart';
import '../../services/value_service.dart';

class DuiFenEHomeworkSettingsPage extends StatefulWidget {
  const DuiFenEHomeworkSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _DuiFenEHomeworkSettingsPageState();
}

class _DuiFenEHomeworkSettingsPageState
    extends State<DuiFenEHomeworkSettingsPage> {
  late bool _isLogin;
  late bool _enableHomeworkNotification;

  @override
  void initState() {
    super.initState();
    _isLogin = GlobalService.duifeneService?.isLogin == true;
    _loadStates();
  }

  Future<void> _loadStates() async {
    _enableHomeworkNotification =
        (DuiFenEBox.get('enableHomeworkNotification') as bool?) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final maxLines = 100;

    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: FScaffold(
        contentPad: false,
        header: FHeader.nested(
          title: const Text(
            '对分易作业设置',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          prefixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.chevronLeft),
                onPress: () => Navigator.of(context).pop())
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              if (!_isLogin)
                Center(
                  child: Text(
                    '未登录对分易',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              buildSettingTileGroup(context, null, [
                FTile(
                  title: const Text('启用作业截止前提醒'),
                  subtitle: Text(
                    '同时包括在线练习和作业，根据下面的设置进行提醒\n\n此功能需要后台服务设置为「后台模式」并对本应用关闭电池优化，否则可能无法及时获取最新作业状态',
                    maxLines: maxLines,
                  ),
                  suffixIcon: FSwitch(
                    enabled: _isLogin,
                    value: _enableHomeworkNotification,
                    onChange: (value) async {},
                  ),
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}
