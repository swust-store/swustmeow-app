import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import 'components/will_pop_scope_blocker.dart';
import 'data/values.dart';
import 'views/main_page.dart';

void main() => runApp(const Application());

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<StatefulWidget> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {
  bool isDarkMode = false;
  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode1 = brightness == Brightness.dark;
    if (!isDarkMode && isDarkMode1) {
      setState(() => isDarkMode = isDarkMode1);
    }
    WidgetsBinding.instance.addObserver(this);

    _checkThemeMode();
  }

  Future<void> _checkThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final tm = prefs.getString('themeMode');
    if (tm == null) {
      await prefs.setString('themeMode', themeMode.name);
    } else {
      setState(() {
        themeMode = ThemeMode.values.where((m) => m.name == tm).first;
        Values.themeMode = themeMode;
      });
    }
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
    final isDarkMode =
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    final overlayStyle = switch (themeMode) {
      ThemeMode.system =>
        isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ThemeMode.light => SystemUiOverlayStyle.dark,
      ThemeMode.dark => SystemUiOverlayStyle.light,
    };
    SystemChrome.setSystemUIOverlayStyle(overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent));

    final theme = switch (themeMode) {
      ThemeMode.system => isDarkMode ? FThemes.zinc.dark : FThemes.zinc.light,
      ThemeMode.light => FThemes.zinc.dark,
      ThemeMode.dark => FThemes.zinc.light,
    };
    final themeData = FThemeData.inherit(
        colorScheme: theme.colorScheme,
        typography: theme.typography.copyWith(
            defaultFontFamily: '未来圆SC',
            base: theme.typography.base.copyWith(fontWeight: FontWeight.bold)));

    return MaterialApp(
      builder: (context, child) {
        var chi = child!;
        chi = ToastificationConfigProvider(
            config: const ToastificationConfig(
              alignment: Alignment.topRight,
            ),
            child: chi);
        chi = FTheme(data: themeData, child: chi);
        return chi;
      },
      home: const WillPopScopeBlocker(child: MainPage()),
    );
  }
}
