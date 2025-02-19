import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/types.dart';
import 'package:swustmeow/views/library_page.dart';
import 'package:swustmeow/views/qun_resource_page.dart';

import '../views/apartment/apartment_page.dart';
import '../views/duifene/duifene_homework_page.dart';
import '../views/duifene/duifene_signin_page.dart';
import '../views/soa/soa_exams_page.dart';
import '../views/soa/soa_leaves_page.dart';
import '../views/soa/soa_map_page.dart';
import '../views/soa/soa_scores_page.dart';
import '../views/soa/soa_ykt_page.dart';
import 'm_theme.dart';

class Values {
  static const name = '西科喵';

  static const version = '1.0.1';

  static const notificationChannelId = 'swuststore';

  static const notificationId = 2233;

  static const showcaseMode = false;

  static late DefaultCacheManager cache;

  static String instruction =
      '$name是一个课表、校历、考试等各类信息的聚合 APP，旨在为西科大学子提供一个易用、简单、舒适的校园一站式服务平台。';

  static String adInstruction =
      '首页滚动可点击跳转广告位现已开放招租，欢迎合作！广告图片需遵循长宽比例 3:1，具体尺寸不限，同时需提供有效的跳转链接。具体投放要求及合作详情，请咨询官方 QQ 群管理员。';

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
    return isFirstTerm
        ? (DateTime(2024, 9, 2), DateTime(2025, 1, 12), 19)
        : (DateTime(2025, 2, 17), DateTime(2025, 7, 13), 21);
  }

  static String fetchInfoUrl = 'https://swust-meow.bluedog233.cn/info.json';

  static TextStyle dialogButtonTextStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  // static ThemeMode? themeMode;

  static ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  static Color fallbackColor = Colors.blue;

  static ShimmerEffect skeletonizerEffect = ShimmerEffect(
      baseColor: Colors.grey[/*isDarkMode ? 800 :*/ 300]!,
      highlightColor: Colors.grey[/*isDarkMode ? 600 :*/ 100]!,
      duration: const Duration(seconds: 1));

  static List<ToolEntry> tools = [
    (
      '考试查询',
      FontAwesomeIcons.penNib,
      MTheme.primary2,
      () => SOAExamsPage(),
      () => GlobalService.soaService,
      true,
    ),
    (
      '成绩查询',
      FontAwesomeIcons.solidStar,
      MTheme.primary2,
      () => SOAScoresPage(),
      () => GlobalService.soaService,
      true,
    ),
    (
      '校园地图',
      FontAwesomeIcons.mapLocationDot,
      MTheme.primary2,
      () => SOAMapPage(),
      () => null,
      true,
    ),
    // (
    //   '辅助选课',
    //   FontAwesomeIcons.bookOpen,
    //   MTheme.primary2,
    //   () => SOASnatchCoursePage(),
    //   () => GlobalService.soaService,
    //   false,
    // ),
    (
      '请假',
      FontAwesomeIcons.solidCalendarPlus,
      MTheme.primary2,
      () => SOALeavesPage(),
      () => GlobalService.soaService,
      true,
    ),
    (
      '一卡通',
      FontAwesomeIcons.solidCreditCard,
      MTheme.primary2,
      () => SOAYKTPage(),
      () => GlobalService.soaService,
      true,
    ),
    (
      '宿舍事务',
      FontAwesomeIcons.solidBuilding,
      Colors.green,
      () => ApartmentPage(),
      () => GlobalService.apartmentService,
      true,
    ),
    (
      '资料库',
      FontAwesomeIcons.bookAtlas,
      Colors.teal,
      () => LibraryPage(),
      () => null,
      true,
    ),
    (
      '西科群聊导航',
      FontAwesomeIcons.userGroup,
      Colors.teal,
      () => QunResourcePage(),
      () => null,
      false,
    ),
    (
      '对分易作业',
      FontAwesomeIcons.solidFile,
      Colors.orange,
      () => DuiFenEHomeworkPage(),
      () => GlobalService.duifeneService,
      true,
    ),
    (
      '对分易签到',
      FontAwesomeIcons.locationDot,
      Colors.orange,
      () => DuiFenESignInPage(),
      () => GlobalService.duifeneService,
      true,
    ),
  ];
}
