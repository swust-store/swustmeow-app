import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/views/home_page.dart';

void main() => runApp(const Application());

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<StatefulWidget> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final isDarkMode = View.of(context).platformDispatcher.platformBrightness ==
        Brightness.dark;
    setState(() => this.isDarkMode = isDarkMode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // 反过来，因为暗黑模式下需要白色的状态栏，反之相同
    final overlayStyle =
        isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    SystemChrome.setSystemUIOverlayStyle(overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent));

    final theme = isDarkMode ? FThemes.zinc.dark : FThemes.zinc.light;
    final themeData = FThemeData.inherit(
        colorScheme: theme.colorScheme,
        typography: theme.typography.copyWith(
            defaultFontFamily: '未来圆SC',
            base: theme.typography.base.copyWith(fontWeight: FontWeight.bold)));

    return MaterialApp(
      builder: (context, child) => FTheme(data: themeData, child: child!),
      home: const HomePage(),
    );
  }
}
