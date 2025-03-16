import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/views/ai/ai_chat_page.dart';
import 'package:swustmeow/views/qun_resource_page.dart';
import 'package:swustmeow/views/ykt/ykt_page.dart';

import '../entity/tool.dart';
import '../views/apartment/apartment_page.dart';
import '../views/duifene/duifene_homework_page.dart';
import '../views/duifene/duifene_signin_page.dart';
import '../views/library/library_page.dart';
import '../views/soa/soa_exams_page.dart';
import '../views/soa/soa_leaves_page.dart';
import '../views/soa/soa_map_page.dart';
import '../views/soa/soa_scores_page.dart';

class Values {
  static const name = '西科喵';

  static const version = '1.0.4';
  static const buildVersion = '1';

  static const notificationChannelId = 'swuststore';

  static const admins = ['REDACTED_ADMIN_ID', 'REDACTED_ADMIN_ID'];

  static const notificationId = 2233;

  static bool showcaseMode = false;

  static late DefaultCacheManager cache;

  static String instruction =
      '$name是一个课表、校历、考试等各类信息的聚合 APP，旨在为西科大学子提供一个易用、简单、舒适的校园一站式服务平台。';

  static String adInstruction =
      '首页滚动可点击跳转广告位现已开放，欢迎合作！广告图片需遵循长宽比例 3:1，具体尺寸不限，同时需提供有效的跳转链接。具体投放要求及合作详情，请咨询官方 QQ 群管理员。';

  static Map<String, List<String>> changelog = {
    '1.0.0': ['初代版本'],
    '1.0.1': [
      '增加了多账号管理功能',
      '增加了对非标准课表的解析支持',
      '增加了首页课程上课剩余时间显示',
      '修复了首页课程问题',
      '修复了登录页和底部导航栏闪烁的问题',
      '删除了每次运行都会弹出的通知',
      '优化了部分样式',
    ],
    '1.0.2': [
      '抛弃后端登录与解析课表，使用安全性更高的前端处理',
      '添加了共享课程表功能',
      '添加了建议反馈功能',
      '添加了对分易定位签到功能',
      '添加了登录显示密码功能',
      '修复了登录后课程表不刷新的问题',
      '修复了潜在的软件开屏白屏问题',
      '修复了日历的事件匹配问题',
      '修复了一些课程表相关的问题',
      '优化了部分页面的 UI',
    ],
    '1.0.3': [
      '添加了多个桌面课程小组件',
      '添加了 iOS 系统支持',
      '添加了 AI 助手功能',
      '接入了 ICP 备案',
      '修复了一些已知的问题',
      '优化了部分页面的 UI',
    ],
    '1.0.4': [
      '添加了一卡通功能',
      '添加了小组件预览',
      '添加了工具可编辑、选择显示的功能',
      '添加了资料库自由上传文件的功能',
      '添加了课程表自定义调色的功能',
      '可以点击桌面小组件进入APP了',
      '可以跳过登录直接使用本地缓存了',
      '解除了10位数学号的限制',
      '修复主页不显示自定义课程的问题',
      '修复了课程表获取失败的问题',
      '修复了可能掉登录的问题',
      '修复了“今天”显示为假期的问题',
      '优化了消息提示的样式',
      '优化了部分页面的 UI',
    ]
  };

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

  static Color fallbackColor = Colors.blue;

  static ShimmerEffect skeletonizerEffect = ShimmerEffect(
      baseColor: Colors.grey[/*isDarkMode ? 800 :*/ 300]!,
      highlightColor: Colors.grey[/*isDarkMode ? 600 :*/ 100]!,
      duration: const Duration(seconds: 1));

  static List<Tool> defaultTools = [
    Tool(
      id: 'exams',
      name: '考试查询',
      path: '/exams',
      icon: FontAwesomeIcons.penNib,
      color: Colors.blue,
      pageBuilder: () => SOAExamsPage(),
      serviceGetter: () => GlobalService.soaService,
      isVisible: true,
      order: 0,
    ),
    Tool(
      id: 'scores',
      name: '成绩查询',
      path: '/scores',
      icon: FontAwesomeIcons.solidStar,
      color: Colors.blue,
      pageBuilder: () => SOAScoresPage(),
      serviceGetter: () => GlobalService.soaService,
      isVisible: true,
      order: 1,
    ),
    Tool(
      id: 'campusMap',
      name: '校园地图',
      path: '/campus_map',
      icon: FontAwesomeIcons.mapLocationDot,
      color: Colors.blue,
      pageBuilder: () => SOAMapPage(),
      serviceGetter: () => null,
      isVisible: true,
      order: 2,
      hiddenInShowcaseMode: true,
    ),
    Tool(
      id: 'leave',
      name: '请假',
      path: '/exams',
      icon: FontAwesomeIcons.solidCalendarPlus,
      color: Colors.blue,
      pageBuilder: () => SOALeavesPage(),
      serviceGetter: () => GlobalService.soaService,
      isVisible: true,
      order: 3,
    ),
    Tool(
      id: 'ykt',
      name: '一卡通',
      path: '/ykt',
      icon: FontAwesomeIcons.solidCreditCard,
      color: Colors.lightBlue,
      pageBuilder: () => YKTPage(),
      serviceGetter: () => GlobalService.yktService,
      isVisible: true,
      order: 4,
      hiddenInShowcaseMode: true,
    ),
    Tool(
      id: 'apartment',
      name: '宿舍事务',
      path: '/apartment',
      icon: FontAwesomeIcons.solidBuilding,
      color: Colors.green,
      pageBuilder: () => ApartmentPage(),
      serviceGetter: () => GlobalService.apartmentService,
      isVisible: true,
      order: 5,

    ),
    Tool(
      id: 'library',
      name: '资料库',
      path: '/library',
      icon: FontAwesomeIcons.bookAtlas,
      color: Colors.teal,
      pageBuilder: () => LibraryPage(),
      serviceGetter: () => null,
      isVisible: true,
      order: 6,
    ),
    Tool(
      id: 'qunResource',
      name: '群聊导航',
      path: '/qun',
      icon: FontAwesomeIcons.userGroup,
      color: Colors.teal,
      pageBuilder: () => QunResourcePage(),
      serviceGetter: () => null,
      isVisible: false,
      order: 7,
    ),
    Tool(
      id: 'duifeneHomework',
      name: '对分易作业',
      path: '/duifene/homework',
      icon: FontAwesomeIcons.solidFile,
      color: Colors.orange,
      pageBuilder: () => DuiFenEHomeworkPage(),
      serviceGetter: () => GlobalService.duifeneService,
      isVisible: true,
      order: 8,
    ),
    Tool(
      id: 'duifeneSignIn',
      name: '对分易签到',
      path: '/duifene/sign_in',
      icon: FontAwesomeIcons.locationDot,
      color: Colors.orange,
      pageBuilder: () => DuiFenESignInPage(),
      serviceGetter: () => GlobalService.duifeneService,
      isVisible: true,
      order: 9,
      hiddenInShowcaseMode: true,
    ),
    Tool(
      id: 'ai',
      name: 'AI 助手',
      path: '/ai_chat',
      icon: FontAwesomeIcons.solidComments,
      color: Color.fromRGBO(0, 123, 255, 1),
      pageBuilder: () => AIChatPage(),
      serviceGetter: () => null,
      isVisible: false,
      order: 11,
    ),
  ];

  // 用于持久化和读取用户自定义工具设置的工具列表
  static ValueNotifier<List<Tool>> tools =
      ValueNotifier<List<Tool>>([...defaultTools]);
}
