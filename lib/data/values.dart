import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swustmeow/views/library_page.dart';
import 'package:swustmeow/views/qun_resource_page.dart';

import '../views/apartment/apartment_page.dart';
import '../views/duifene/duifene_homework_page.dart';
import '../views/duifene/duifene_signin_settings_page.dart';
import '../views/soa/soa_exams_page.dart';
import '../views/soa/soa_leaves_page.dart';
import '../views/soa/soa_map_page.dart';
import '../views/soa/soa_scores_page.dart';
import '../views/soa/soa_snatch_course_page.dart';
import '../views/soa/soa_ykt_page.dart';
import 'm_theme.dart';

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

  // static ThemeMode? themeMode;

  static ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  static Color fallbackColor = Colors.blue;

  static ShimmerEffect skeletonizerEffect = ShimmerEffect(
      baseColor: Colors.grey[/*isDarkMode ? 800 :*/ 300]!,
      highlightColor: Colors.grey[/*isDarkMode ? 600 :*/ 100]!,
      duration: const Duration(seconds: 1));

  /// 分别表示：名字，图标，图标颜色，构造器，是否展示在主页
  static List<(String, IconData, Color, StatefulWidget Function(), bool)>
      tools = [
    (
      '一卡通',
      FontAwesomeIcons.solidCreditCard,
      MTheme.primary2,
      () => SOAYKTPage(),
      true,
    ),
    (
      '考试查询',
      FontAwesomeIcons.penNib,
      MTheme.primary2,
      () => SOAExamsPage(),
      true,
    ),
    (
      '成绩查询',
      FontAwesomeIcons.solidStar,
      MTheme.primary2,
      () => SoaScoresPage(),
      true,
    ),
    (
      '校园地图',
      FontAwesomeIcons.mapLocationDot,
      MTheme.primary2,
      () => SOAMapPage(),
      true,
    ),
    (
      '选课',
      FontAwesomeIcons.bookOpen,
      MTheme.primary2,
      () => SOASnatchCoursePage(),
      false,
    ),
    (
      '请假',
      FontAwesomeIcons.solidCalendarPlus,
      MTheme.primary2,
      () => SOALeavesPage(),
      true,
    ),
    (
      '宿舍事务',
      FontAwesomeIcons.solidBuilding,
      Colors.green,
      () => ApartmentPage(),
      true,
    ),
    (
      '资料库',
      FontAwesomeIcons.bookAtlas,
      Colors.teal,
      () => LibraryPage(),
      true,
    ),
    (
      '西科群聊导航',
      FontAwesomeIcons.userGroup,
      Colors.teal,
      () => QunResourcePage(),
      false,
    ),
    (
      '对分易签到',
      FontAwesomeIcons.locationDot,
      Colors.orange,
      () => DuiFenESignInSettingsPage(),
      true,
    ),
    (
      '对分易作业',
      FontAwesomeIcons.solidFile,
      Colors.orange,
      () => DuiFenEHomeworkPage(),
      true,
    ),
  ];
}
