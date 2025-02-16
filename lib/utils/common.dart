import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> clearCaches() async {
  // 清除缓存
  await Values.cache.emptyCache();
  ValueService.clearCache();

  // 清除所有 Box
  await BoxService.clearCache();
  await BoxService.open();

  // 重载 `GlobalService`
  await GlobalService.load();
}

void showToast({
  required BuildContext context,
  required ToastificationType type,
  required String message,
  Alignment? alignment = Alignment.topCenter,
  int seconds = 3,
}) {
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
    title: AutoSizeText(
      message,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ),
    backgroundColor: context.theme.colorScheme.primaryForeground,
    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
    autoCloseDuration: Duration(seconds: seconds),
    style: ToastificationStyle.flat,
    showProgressBar: false,
    alignment: alignment,
    dragToClose: true,
    type: type,
  );
}

void showInfoToast(
  BuildContext context,
  String message, {
  Alignment? alignment,
  int seconds = 3,
}) =>
    showToast(
      context: context,
      type: ToastificationType.info,
      message: message,
      alignment: alignment,
      seconds: seconds,
    );

void showSuccessToast(
  BuildContext context,
  String message, {
  Alignment? alignment,
  int seconds = 3,
}) =>
    showToast(
      context: context,
      type: ToastificationType.success,
      message: message,
      alignment: alignment,
      seconds: seconds,
    );

void showWarningToast(
  BuildContext context,
  String message, {
  Alignment? alignment,
  int seconds = 3,
}) =>
    showToast(
      context: context,
      type: ToastificationType.warning,
      message: message,
      alignment: alignment,
      seconds: seconds,
    );

void showErrorToast(
  BuildContext context,
  String message, {
  Alignment? alignment,
  int seconds = 3,
}) =>
    showToast(
      context: context,
      type: ToastificationType.error,
      message: message,
      alignment: alignment,
      seconds: seconds,
    );

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
