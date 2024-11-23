import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/empty.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/bottom_navbar.dart';
import '../components/m_scaffold.dart';
import '../components/padding_container.dart';
import '../utils/router.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLogin = false;
  bool isFirstTime = false;

  @override
  void initState() {
    super.initState();
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
    if (isFirstTime) {
      // pushTo(context, const Instruction());
      pushTo(context, const LoginPage());
      // pushTo(context, const CourseTablePage());
      return const Empty();
    }

    return const MScaffold(FScaffold(
        footer: BottomNavBar(), // 目前版本不开放底部导航栏
        content: PaddingContainer(Column(
          children: [],
        ))));
  }
}
