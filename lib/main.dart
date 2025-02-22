import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forui/forui.dart';
import 'package:hive/hive.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/hive_adapter_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swustmeow/services/umeng_service.dart';
import 'package:toastification/toastification.dart';

import 'components/utils/back_again_blocker.dart';
import 'data/values.dart';
import 'views/main_page.dart';

Future<void> main() async {
  debugPaintPointersEnabled = false;

  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  final has = HiveAdapterService();
  has.register();

  // 初始化缓存
  Values.cache = DefaultCacheManager();
  await BoxService.open();

  // 初始化服务
  await GlobalService.load();

  // 加载本地化
  await initializeDateFormatting('zh');

  // 加载 InAppWebview
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  // 初始化友盟 SDK
  UmengService.initUmeng();

  runApp(const Application());
}

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<StatefulWidget> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {
  bool isDarkMode = false;

  // ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode1 = brightness == Brightness.dark;
    if (!isDarkMode && isDarkMode1) {
      Values.isDarkMode.value = isDarkMode1;
      setState(() => isDarkMode = isDarkMode1);
    }
    WidgetsBinding.instance.addObserver(this);
    //
    // _checkThemeMode();
  }

  // Future<void> _checkThemeMode() async {
  //   final box = BoxService.commonBox;
  //   final tm = box.get('themeMode') as String?;
  //   if (tm == null) {
  //     await box.put('themeMode', themeMode.name);
  //   } else {
  //     setState(() {
  //       themeMode = ThemeMode.values.where((m) => m.name == tm).first;
  //       Values.themeMode = themeMode;
  //     });
  //   }
  // }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final isDarkMode = View.of(context).platformDispatcher.platformBrightness ==
        Brightness.dark;
    Values.isDarkMode.value = isDarkMode;
    setState(() => this.isDarkMode = isDarkMode);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      GlobalService.dispose();
    }
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
    // final overlayStyle = switch (themeMode) {
    //   ThemeMode.system =>
    //     isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    //   ThemeMode.light => SystemUiOverlayStyle.dark,
    //   ThemeMode.dark => SystemUiOverlayStyle.light,
    // };
    // final overlayStyle = SystemUiOverlayStyle.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    // .copyWith(
    //     cardStyle: theme.cardStyle.copyWith(
    //         decoration: theme.cardStyle.decoration.copyWith(
    //             color: isDarkMode
    //                 ? theme.colorScheme.primaryForeground
    //                 : null)),
    //     tileGroupStyle: theme.tileGroupStyle.copyWith(
    //         tileStyle: theme.tileGroupStyle.tileStyle.copyWith(
    //             enabledBackgroundColor: isDarkMode
    //                 ? theme.colorScheme.primaryForeground
    //                 : null)),
    //     selectGroupStyle: theme.selectGroupStyle.copyWith());

    return MaterialApp(
      theme: ThemeData(primaryColor: MTheme.primary2),
      localizationsDelegates: const [
        FLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh')],
      builder: (context, child) {
        var chi = child!;
        chi = IconTheme.merge(data: IconThemeData(size: 18.0), child: child);
        chi = ToastificationConfigProvider(
            config: const ToastificationConfig(alignment: Alignment.topRight),
            child: chi);
        chi = FTheme(data: MTheme.themeData, child: chi);
        return chi;
      },
      home: const BackAgainBlocker(child: MainPage()),
    );
  }
}
