import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/views/homepage.dart';

void main() => runApp(const Application());

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = FThemeData.inherit(
        colorScheme: FThemes.zinc.light.colorScheme,
        typography:
            FThemes.zinc.light.typography.copyWith(defaultFontFamily: '未来圆SC'));
    return MaterialApp(
      builder: (context, child) => FTheme(data: themeData, child: child!),
      home: const Homepage(),
    );
  }
}
