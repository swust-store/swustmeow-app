import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Values {
  static const String name = '西科喵';

  static const String version = '1.0.0-dev';

  static const notificationChannelId = 'swuststore';
  static const notificationId = 2233;

  static late DefaultCacheManager cache;

  static String instruction =
      '$name是一个课表、校历、考试等各类信息的聚合 APP，旨在为西科大学子提供一个易用、简单、舒适的校园一站式服务平台。';

  static String agreementPrompt =
      '为了更好地保障您的合法权益，并为您提供更好的使用体验，请您阅读并同意协议以继续使用$name。';

  static List<String> courseTableTimes = [
    '08:00\n09:40',
    '10:00\n11:40',
    '14:00\n15:40',
    '16:00\n17:40',
    '19:00\n20:40',
    '20:40\n22:40'
  ];

  static (DateTime, DateTime, int) getFallbackTermDates(String term) {
    final isFirstTerm = term.endsWith('上');
    return isFirstTerm
        ? (DateTime(2024, 9, 2), DateTime(2025, 1, 12), 19)
        : (DateTime(2025, 2, 17), DateTime(2025, 7, 13), 21);
  }

  static String fetchInfoUrl = 'http://61.139.65.237:90/static/info.json';

  static TextStyle dialogButtonTextStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  static ThemeMode? themeMode;

  static bool isDarkMode =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;

  static Color fallbackColor = Colors.purple;

  static ValueNotifier<bool> isFlipEnabled = ValueNotifier(false);

  static ShimmerEffect skeletonizerEffect = ShimmerEffect(
      baseColor: Colors.grey[isDarkMode ? 800 : 300]!,
      highlightColor: Colors.grey[isDarkMode ? 600 : 100]!,
      duration: const Duration(seconds: 1));
}
