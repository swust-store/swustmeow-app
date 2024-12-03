import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/empty.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';
import 'package:miaomiaoswust/views/instruction_page.dart';
import 'package:miaomiaoswust/views/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/froster_scaffold.dart';
import '../components/m_scaffold.dart';
import '../utils/router.dart';
import 'home_page.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({this.index, super.key});

  final int? index;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLogin = true;
  bool isFirstTime = false;
  Widget currentPage = const CourseTablePage();
  int index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.index != null) setState(() => index = widget.index!);
    _loadStates();
  }

  _loadStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = (prefs.getBool('isLogin') ?? false);
      isFirstTime = (prefs.getBool('isFirstTime') ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      // FBottomNavigationBarItem(
      //     label: const Text('课程表'),
      //     icon: FIcon(
      //       FAssets.icons.bookText,
      //     )),
      FBottomNavigationBarItem(
          label: const Text('主页'), icon: FIcon(FAssets.icons.house)),
      FBottomNavigationBarItem(
          label: const Text('设置'), icon: FIcon(FAssets.icons.settings))
    ];

    final contents = [const HomePage(), const SettingsPage()];

    if (isFirstTime) {
      pushTo(context, const InstructionPage());
      return const Empty();
    }

    if (!isLogin) {
      pushTo(context, const LoginPage());
      return const Empty();
    }

    return MScaffold(
      safeArea: false,
      safeBottom: false,
      FrostedScaffold(
        contentPad: false,
        content: contents[index],
        footer: FBottomNavigationBar(
            index: index,
            onChange: (index) => setState(() => this.index = index),
            children: children),
      ),
    );
  }
}
