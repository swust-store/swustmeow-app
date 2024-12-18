import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/empty.dart';
import '../components/froster_scaffold.dart';
import '../components/m_scaffold.dart';
import '../utils/router.dart';
import '../views/settings_page.dart';
import 'home_page.dart';
import 'instruction_page.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.index});

  final int? index;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLogin = true;
  bool isFirstTime = false;
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
      child: FrostedScaffold(
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
