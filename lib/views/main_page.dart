import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/views/todo_page.dart';

import '../components/froster_scaffold.dart';
import '../components/utils/empty.dart';
import '../components/utils/m_scaffold.dart';
import '../data/m_theme.dart';
import '../services/value_service.dart';
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
  final pages = [
    ('首页', FontAwesomeIcons.house, HomePage()),
    ('待办', FontAwesomeIcons.tableList, TodoPage()),
    ('设置', FontAwesomeIcons.gear, SettingsPage())
  ];

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _refresh(() => _index = widget.index!));
    }
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalService.size = MediaQuery.of(context).size;

    if (!Values.showcaseMode && GlobalService.soaService?.isLogin != true) {
      pushReplacement(context, const InstructionPage(), pushInto: true);
      return const Empty();
    }

    final (_, _, content) = pages[_index];
    return ValueListenableBuilder(
        valueListenable: ValueService.isFlipEnabled,
        builder: (context, value, child) {
          return Transform.flip(
            flipX: value,
            flipY: value,
            child: MScaffold(
              safeArea: false,
              safeBottom: false,
              child: FrostedScaffold(
                contentPad: false,
                content: content,
                footer: FBottomNavigationBar(
                    index: _index,
                    onChange: (index) {
                      _refresh(() => _index = index);
                    },
                    children: pages.map((data) {
                      final (label, icon, _) = data;
                      final color =
                          pages[_index] == data ? MTheme.primary2 : Colors.grey;
                      return FBottomNavigationBarItem(
                          label: Text(
                            label,
                            style: TextStyle(color: color, fontSize: 10),
                          ),
                          icon: FaIcon(icon, color: color, size: 20));
                    }).toList()),
              ),
            ),
          );
        });
  }
}
