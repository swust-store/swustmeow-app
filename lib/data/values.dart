import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../entity/server_info.dart';

class Values {
  static String get version => '1.0.0-dev';

  static late DefaultCacheManager cache;

  static String get instruction =>
      '「喵喵西科」是一个课表、校历、考试等各类信息的聚合 APP，旨在为西科大学子提供一个易用、简单、舒适的校园一站式服务平台。';

  static String get agreementPrompt =>
      '为了更好地保障您的合法权益，并为您提供更好的使用体验，请您阅读并同意协议以继续使用「喵喵西科」。';

  static DateTime get courseBeginTime => DateTime(2024, 9, 2);

  static ImageProvider get loginBgImage =>
      const AssetImage('assets/images/login_bg.jpg');

  static ImageProvider get catLoadingGif =>
      const AssetImage('assets/images/dancing_kitty_black.gif');

  static List<String> get courseTableTimes => [
        '08:00\n09:40',
        '10:00\n11:40',
        '14:00\n15:40',
        '16:00\n17:40',
        '19:00\n20:40',
        '20:40\n22:40'
      ];

  static String get fetchInfoUrl => 'http://110.40.79.230:90/static/info.json';

  static String get fetchActivitiesUrl => 'http://110.40.79.230:90/static/activities.json';

  static Future<ServerInfo> get serverInfo async => ServerInfo.fetch();

  static TextStyle get dialogButtonTextStyle =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  static ThemeMode? themeMode;

  static bool get isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  static Color get fallbackColor => Colors.purple;

  static ValueNotifier<bool> isFlipEnabled = ValueNotifier(false);
}
