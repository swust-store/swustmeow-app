import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/views/chaoxing/chaoxing_homework_page.dart';

import '../entity/tool.dart';
import '../services/color_service.dart';
import '../services/global_service.dart';
import '../views/ai/ai_chat_page.dart';
import '../views/apartment/apartment_page.dart';
import '../views/duifene/duifene_homework_page.dart';
import '../views/duifene/duifene_signin_page.dart';
import '../views/library/library_page.dart';
import '../views/qun_resource_page.dart';
import '../views/soa/soa_exams_page.dart';
import '../views/soa/soa_leaves_page.dart';
import '../views/soa/soa_map_page.dart';
import '../views/soa/soa_scores_page.dart';
import '../views/ykt/ykt_page.dart';

class Tools {
  static List<Tool> defaultTools = [
    Tool(
      id: 'exams',
      name: '考试查询',
      path: '/exams',
      icon: FontAwesomeIcons.penNib,
      color: ColorService.soaColor,
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
      color: ColorService.soaColor,
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
      color: ColorService.soaColor,
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
      color: ColorService.soaColor,
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
      color: ColorService.yktColor,
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
      color: ColorService.apartmentColor,
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
      color: ColorService.libraryColor,
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
      color: ColorService.qunColor,
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
      color: ColorService.duifeneColor,
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
      color: ColorService.duifeneColor,
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
      color: ColorService.aiColor,
      pageBuilder: () => AIChatPage(),
      serviceGetter: () => null,
      isVisible: false,
      order: 11,
    ),
    Tool(
      id: 'chaoxingHomework',
      name: '学习通作业',
      path: '/chaoxing/homework',
      icon: FontAwesomeIcons.solidFile,
      color: ColorService.chaoxingColor,
      pageBuilder: () => ChaoXingHomeworkPage(),
      serviceGetter: () => GlobalService.chaoXingService,
      isVisible: true,
      order: 12,
    ),
  ];

  static ValueNotifier<List<Tool>> tools =
      ValueNotifier<List<Tool>>([...defaultTools]);
}
