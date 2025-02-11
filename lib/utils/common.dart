import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> clearCaches() async {
  // 清除缓存
  await Values.cache.emptyCache();

  // 清除所有 Box
  await BoxService.clear();
  await BoxService.open();

  // 重载 `GlobalService`
  await GlobalService.load();
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

void showInfoToast(BuildContext context, String message,
        {Alignment? alignment = Alignment.bottomCenter}) =>
    showToast(
        context: context,
        type: ToastificationType.info,
        message: message,
        alignment: alignment);

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

Future<bool> launchLink(String link) async {
  final uri = Uri.parse(link);
  if (await canLaunchUrl(uri)) {
    final result = await launchUrlString(
      link,
      mode: uri.scheme.startsWith('http')
          ? LaunchMode.externalApplication
          : LaunchMode.externalNonBrowserApplication,
    );
    debugPrint('跳转结果：$result -> $uri');
    return result;
  } else {
    return false;
  }
}
