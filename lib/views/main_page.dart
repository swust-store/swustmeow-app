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
  bool _isLogin = true;
  bool _isFirstTime = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.index != null) setState(() => _index = widget.index!);
    _loadStates();
  }

  Future<void> _loadStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLogin = (prefs.getBool('isLogin') ?? false);
      _isFirstTime = (prefs.getBool('isFirstTime') ?? true);
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

    if (_isFirstTime) {
      pushTo(context, const InstructionPage());
      return const Empty();
    }

    if (!_isLogin) {
      pushTo(context, const LoginPage());
      return const Empty();
    }

    return MScaffold(
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
    );
  }
}
