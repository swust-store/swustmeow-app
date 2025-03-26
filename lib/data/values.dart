import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Values {
  static const name = '易通西科喵';

  static const version = '1.0.5';
  static const buildVersion = '4';

  static const notificationChannelId = 'swuststore';

  static const admins = ['REDACTED_ADMIN_ID', 'REDACTED_ADMIN_ID'];

  static const notificationId = 2233;

  static bool showcaseMode = false;

  static late DefaultCacheManager cache;

  static String instruction =
      '$name是一个课表、校历、考试等各类信息的聚合 APP，旨在为西科大学子提供一个易用、简单、舒适的校园一站式服务平台。';

  static String adInstruction =
      '首页滚动可点击跳转广告位现已开放，欢迎合作！广告图片需遵循长宽比例 3:1，具体尺寸不限，同时需提供有效的跳转链接。具体投放要求及合作详情，请咨询官方 QQ 群管理员。';

  static List<String> courseTableTimes = [
    '08:00\n09:40',
    '10:00\n11:40',
    '14:00\n15:40',
    '16:00\n17:40',
    '19:00\n20:40',
    '20:40\n22:00'
  ];

  static (DateTime, DateTime, int) getFallbackTermDates(String term) {
    final isFirstTerm = term.endsWith('上');
    final year = DateTime.now().year;
    return isFirstTerm
        ? (DateTime(year - 1, 9, 2), DateTime(year, 1, 12), 19)
        : (DateTime(year, 2, 17), DateTime(year, 7, 13), 21);
  }

  static String get fallbackTerm {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    if ((month >= 8 && month <= 12) || month == 1) {
      return '$year-${year + 1}-上';
    } else if (month >= 2 && month <= 7) {
      return '${year - 1}-$year-下';
    }

    return '$year-${year + 1}-上';
  }

  static String fetchInfoUrl = 'https://api.s-meow.com/api/v1/public';
  static String qunUrl = 'https://s-meow.com/qun.html';

  static TextStyle dialogButtonTextStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  // static ThemeMode? themeMode;

  static ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  static ShimmerEffect skeletonizerEffect = ShimmerEffect(
      baseColor: Colors.grey[/*isDarkMode ? 800 :*/ 300]!,
      highlightColor: Colors.grey[/*isDarkMode ? 600 :*/ 100]!,
      duration: const Duration(seconds: 1));
}
