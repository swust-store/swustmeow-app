import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

// import 'package:miaomiaoswust/components/bottom_navbar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<StatefulWidget> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) => Container(
      color: context.theme.colorScheme.background,
      child: const SafeArea(
          child: FScaffold(
        // footer: BottomNavBar(), // 目前版本不开放底部导航栏
        content: Column(
          children: [],
        ),
      )));
}
