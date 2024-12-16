import 'package:flutter/material.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

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

void showToast(
    {required BuildContext context,
    required ToastificationType type,
    required String message}) {
  Color color = Colors.black;
  switch (type) {
    case ToastificationType.success:
      color = Colors.green;
    case ToastificationType.warning:
      color = Colors.orange;
    case ToastificationType.error:
      color = Colors.red;
    default:
      color = color;
  }
  toastification.show(
      context: context,
      title: Text(
        message,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.simple,
      showProgressBar: false,
      alignment: Alignment.topCenter);
}

void showSuccessToast(BuildContext context, String message) => showToast(
    context: context, type: ToastificationType.success, message: message);

void showErrorToast(BuildContext context, String message) => showToast(
    context: context, type: ToastificationType.error, message: message);
