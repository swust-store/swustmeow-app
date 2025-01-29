import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/empty.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/views/tools_page.dart';

import '../components/froster_scaffold.dart';
import '../components/m_scaffold.dart';
import '../utils/router.dart';
import '../views/settings_page.dart';
import 'home_page.dart';
import 'instruction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.index});

  final int? index;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _index = widget.index!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      FBottomNavigationBarItem(
          label: const Text('主页'), icon: FIcon(FAssets.icons.house)),
      FBottomNavigationBarItem(
          label: const Text('工具'), icon: FIcon(FAssets.icons.layoutPanelLeft)),
      FBottomNavigationBarItem(
          label: const Text('设置'), icon: FIcon(FAssets.icons.settings))
    ];

    final contents = [
      const HomePage(),
      const ToolsPage(),
      const SettingsPage()
    ];

    // if (GlobalService.soaService?.isLogin != true) {
    //   pushReplacement(context, const InstructionPage());
    //   return const Empty();
    // }
    //

    return ValueListenableBuilder(
        valueListenable: Values.isFlipEnabled,
        builder: (context, value, child) {
          return Transform.flip(
            flipX: value,
            flipY: value,
            child: MScaffold(
              safeArea: false,
              safeBottom: false,
              child: FrostedScaffold(
                contentPad: false,
                content: contents[_index],
                footer: FBottomNavigationBar(
                    index: _index,
                    onChange: (index) => setState(() => _index = index),
                    children: children),
              ),
            ),
          );
        });
  }
}
