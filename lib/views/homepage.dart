import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
// import 'package:miaomiaoswust/components/bottom_navbar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<StatefulWidget> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) => const FScaffold(
        // footer: BottomNavBar(), // 目前版本不开放底部导航栏
        content: Column(
          children: [],
        ),
      );
}
