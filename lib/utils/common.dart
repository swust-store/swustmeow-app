import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import '../views/main_page.dart';

Future<void> clearCaches() async {
  // 清除 `SharedPreferences` 中的缓存
  final prefs = await SharedPreferences.getInstance();
  final keys = [
    'serverInfo',
    'hitokoto',
    'extraActivities',
    'extraActivitiesLastCheck'
  ];
  for (final key in keys) {
    await prefs.remove(key);
  }

  // 清除缓存
  await Values.cache.emptyCache();

  // 清除所有 Box
  await BoxService.clear();
  await BoxService.open();

  // 重载 `GlobalService`
  await GlobalService.load();
}

Future<void> logOut(final BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isSOALogin', false);
  if (context.mounted) {
    pushTo(context, const MainPage());
  }
}

void showToast(
    {required BuildContext context,
    required ToastificationType type,
    required String message,
    Alignment? alignment = Alignment.bottomCenter}) {
  Color color = context.theme.colorScheme.primary;
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
    backgroundColor: context.theme.colorScheme.primaryForeground,
    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
    autoCloseDuration: const Duration(seconds: 3),
    style: ToastificationStyle.simple,
    showProgressBar: false,
    alignment: alignment,
    dragToClose: true,
  );
}

void showSuccessToast(BuildContext context, String message,
        {Alignment? alignment = Alignment.bottomCenter}) =>
    showToast(
        context: context,
        type: ToastificationType.success,
        message: message,
        alignment: alignment);

void showErrorToast(BuildContext context, String message,
        {Alignment? alignment = Alignment.bottomCenter}) =>
    showToast(
        context: context,
        type: ToastificationType.error,
        message: message,
        alignment: alignment);
