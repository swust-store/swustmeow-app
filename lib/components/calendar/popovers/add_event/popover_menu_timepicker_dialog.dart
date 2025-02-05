import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

Future<void> showPopoverMenuTimepickerDialog(BuildContext context,
    {required TimeOfDay initialTime,
    required Function(TimeOfDay) onTimeSelected}) async {
  final tod = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: '选定一个时间',
      cancelText: '取消',
      confirmText: '确定',
      builder: (context, child) {
        final c = context.theme.colorScheme;
        final s = TextStyle(fontWeight: FontWeight.bold, color: c.primary);
        return Theme(
            data: Theme.of(context).copyWith(
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(textStyle: s)),
                textTheme: TextTheme(bodyMedium: s.copyWith(fontSize: 18)),
                colorScheme: /*Values.isDarkMode
                    ? ColorScheme.dark(
                        primary: c.primary, onPrimary: c.primaryForeground)
                    :*/
                    ColorScheme.light(
                        primary: c.primary, onPrimary: c.primaryForeground)),
            child: child!);
      });
  if (tod != null) {
    onTimeSelected(tod);
  }
}
