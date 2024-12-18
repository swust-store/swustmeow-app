import 'package:flutter/material.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import '../views/main_page.dart';

Future<void> clearCaches() async {
  // 清除缓存
  await Values.cache.emptyCache();

  // 清除所有 Box
  await BoxService.calendarEventListBox.clear();
  await BoxService.courseEntryListBox.clear();
  await BoxService.clear();
  await BoxService.open();
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
