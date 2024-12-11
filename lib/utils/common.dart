import 'package:flutter/material.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/main_page.dart';

Future<void> clearCaches() async {
  final prefs = await SharedPreferences.getInstance();

  // 清除课表
  await prefs.remove('courseTableEntity');
}

Future<void> logOut(final BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLogin', false);
  if (context.mounted) {
    pushTo(context, const MainPage());
  }
}
