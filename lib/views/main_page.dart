import 'dart:io';

import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/boxes/common_box.dart';
import 'package:swustmeow/services/boxes/soa_box.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/views/course_table/course_table_page.dart';
import 'package:swustmeow/views/todo_page.dart';

import '../api/swuststore_api.dart';
import '../components/utils/empty.dart';
import '../components/utils/m_scaffold.dart';
import '../data/activities_store.dart';
import '../data/m_theme.dart';
import '../data/global_keys.dart';
import '../data/showcase_values.dart';
import '../entity/activity.dart';
import '../entity/bottom_navigation_item_page_data.dart';
import '../entity/soa/course/courses_container.dart';
import '../services/boxes/activities_box.dart';
import '../services/boxes/course_box.dart';
import '../services/value_service.dart';
import '../utils/common.dart';
import '../utils/courses.dart';
import '../utils/router.dart';
import '../utils/status.dart';
import 'settings/settings_page.dart';
import 'home_page.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.index});

  final int? index;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isFirstTime = false;
  late BuildContext _showcaseContext;
  late List<GlobalKey> _showcaseKeys;
  bool _hasStartedShowcase = false;
  int _index = 0;
  late List<BottomNavigationItemPageData> pages;
  List<Key> _pageKeys = [];

  @override
  void initState() {
    super.initState();
    ValueService.activities =
        defaultActivities + GlobalService.extraActivities.value;
    _loadActivities();
    if (!Values.showcaseMode &&
        GlobalService.soaService?.currentAccount != null) {
      _reload();
    } else {
      ValueService.isCourseLoading.value = false;
    }

    pages = [
      BottomNavigationItemPageData(
        name: '首页',
        icon: FontAwesomeIcons.house,
        displayGetter: () => true,
        pageGetter: () => HomePage(
          onRefresh: () => _reload(force: true),
        ),
      ),
      BottomNavigationItemPageData(
        name: '课程表',
        icon: FontAwesomeIcons.tableCells,
        displayGetter: () => ValueService.currentCoursesContainer != null,
        pageGetter: () {
          if (ValueService.currentCoursesContainer == null) {
            showErrorToast('当前无课程表，请刷新后重试');
            return null;
          }
          return CourseTablePage(
            containers: !Values.showcaseMode
                ? ValueService.coursesContainers
                : ShowcaseValues.coursesContainers,
            currentContainer: !Values.showcaseMode
                ? ValueService.currentCoursesContainer!
                : ShowcaseValues.coursesContainers.first,
            activities: ValueService.activities,
            showBackButton: false,
          );
        },
      ),
      BottomNavigationItemPageData(
        name: '待办',
        icon: FontAwesomeIcons.tableList,
        displayGetter: () => true,
        pageGetter: () => TodoPage(),
      ),
      BottomNavigationItemPageData(
        name: '设置',
        icon: FontAwesomeIcons.gear,
        displayGetter: () => true,
        pageGetter: () => SettingsPage(onRefresh: () {
          _forceRefreshPages();
        }),
      ),
    ];

    _isFirstTime = CommonBox.get('isFirstTime') ?? true;
    if (widget.index != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _refresh(() => _index = widget.index!));
    }

    _showcaseKeys = [
      GlobalKeys.showcaseCourseTableKey,
      GlobalKeys.showcaseCalendarKey,
      GlobalKeys.showcaseCourseCardsKey,
      GlobalKeys.showcaseToolGridKey,
    ];

    _initPageKeys();

    if (['testaccount', '测试账号']
        .contains(SOABox.get('username') as String? ?? '')) {
      Values.showcaseMode = true;
    }
  }

  Future<void> _reload({bool force = false}) async {
    ValueService.customCourses =
        (CourseBox.get('customCourses') as Map<dynamic, dynamic>? ?? {}).cast();

    if (ValueService.needCheckCourses ||
        ValueService.currentCoursesContainer == null ||
        force ||
        ValueService.cacheSuccess == false) {
      await _loadCourseContainers();
      final service = FlutterBackgroundService();
      service.invoke('duifeneCurrentCourse', {
        'term': ValueService.currentCoursesContainer?.term,
        'entries': (ValueService.currentCoursesContainer?.entries ?? [])
            .map((entry) => entry.toJson())
            .toList()
      });
    } else {
      ValueService.isCourseLoading.value = false;
    }
  }

  Future<void> _loadActivities() async {
    List<Activity>? extra =
        (ActivitiesBox.get('extraActivities') as List<dynamic>?)?.cast();
    if (extra == null) return;
    ValueService.activities = defaultActivities + extra;
  }

  Future<void> _loadCourseContainers() async {
    // 无本地缓存，尝试获取
    if (GlobalService.soaService == null) {
      showErrorToast('本地服务未启动，请重启应用！');
      ValueService.isCourseLoading.value = false;
      return;
    }

    final res = await GlobalService.soaService!.getCourseTables();

    if (res.status != Status.ok &&
        res.status != Status.okWithToast &&
        res.status != Status.partiallyOkWithToast) {
      if (res.value != '未登录') {
        showErrorToast(res.message ?? res.value ?? '未知错误，请重试');
      }

      ValueService.isCourseLoading.value = false;
      return;
    }

    if (res.status == Status.partiallyOkWithToast) {
      showErrorToast(res.message ?? '未完整获取到所有课表');
      ValueService.isCourseLoading.value = false;
    }

    List<CoursesContainer> containers = (res.value as List<dynamic>).cast();
    if (containers.isEmpty) {
      showErrorToast('无法获取课程表，请稍后再试');
      ValueService.isCourseLoading.value = false;
      return;
    }

    final containersWithCustomCourses =
        containers.map((cc) => cc.withCustomCourses).toList();
    _refresh(
        () => ValueService.coursesContainers = containersWithCustomCourses);

    final current = getCurrentCoursesContainer(
        ValueService.activities, containersWithCustomCourses);
    final (today, currentCourse, nextCourse) =
        getCourse(current.term, current.entries);
    _refresh(() {
      ValueService.needCheckCourses = false;
      ValueService.todayCourses = today;
      ValueService.currentCoursesContainer = current;
      ValueService.currentCourse = currentCourse;
      ValueService.nextCourse = nextCourse;
      ValueService.isCourseLoading.value = false;
      GlobalService.refreshHomeCourseWidgets();
    });

    final account = GlobalService.soaService?.currentAccount?.account;
    final sharedContainersResult =
        await SWUSTStoreApiService.getAllSharedCourseTables(account ?? '');
    if (sharedContainersResult.status != Status.ok) {
      showErrorToast('获取共享课表失败：${sharedContainersResult.value}');
    }

    List<CoursesContainer> sharedContainers =
        (sharedContainersResult.value as List<dynamic>).cast();

    final remarkMap =
        CourseBox.get('remarkMap') as Map<dynamic, dynamic>? ?? {};
    for (final sharedContainer in sharedContainers) {
      sharedContainer.remark = remarkMap[sharedContainer.sharerId];
    }

    await CourseBox.put('sharedContainers', sharedContainers);

    _refresh(() {
      ValueService.sharedContainers = sharedContainers;
    });
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  void _initPageKeys() {
    _pageKeys = List.generate(pages.length, (index) => UniqueKey());
  }

  void _forceRefreshPages() {
    _initPageKeys();
    _refresh(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    GlobalService.mediaQueryData = mq;
    GlobalService.size = mq.size;
    final isGestures = mq.systemGestureInsets.left != 0;

    if (!Values.showcaseMode &&
        GlobalService.soaService?.isLogin != true &&
        !ValueService.cacheSuccess) {
      pushReplacement(context, '/login', const LoginPage(), pushInto: true);
      return const Empty();
    }

    final body = _buildShowcaseBody();
    return isGestures
        ? body
        : SafeArea(
            top: false,
            child: body,
          );
  }

  Widget _buildShowcaseBody() {
    return ShowCaseWidget(
      disableBarrierInteraction: true,
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: Padding(
          padding: EdgeInsets.all(MTheme.radius),
          child: ElevatedButton(
            onPressed: () {
              CommonBox.put('isFirstTime', false);
              ShowCaseWidget.of(showcaseContext).dismiss();
            },
            style: ElevatedButton.styleFrom(backgroundColor: MTheme.primary2),
            child: Text('跳过', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      globalTooltipActionConfig: TooltipActionConfig(
        position: TooltipActionPosition.outside,
        alignment: MainAxisAlignment.end,
        actionGap: 2,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          name: '上一个',
          type: TooltipDefaultActionType.previous,
          textStyle: TextStyle(color: Colors.white),
          hideActionWidgetForShowcase: [_showcaseKeys.first],
          backgroundColor: Colors.transparent,
        ),
        TooltipActionButton(
          name: '下一个',
          type: TooltipDefaultActionType.next,
          textStyle: TextStyle(color: Colors.white),
          hideActionWidgetForShowcase: [_showcaseKeys.last],
          backgroundColor: MTheme.primary2,
        ),
        TooltipActionButton(
            name: '完成',
            type: TooltipDefaultActionType.skip,
            textStyle: TextStyle(color: Colors.white),
            hideActionWidgetForShowcase:
                _showcaseKeys.sublist(0, _showcaseKeys.length - 1),
            backgroundColor: MTheme.primary2,
            onTap: () {
              CommonBox.put('isFirstTime', false);
              ShowCaseWidget.of(_showcaseContext).dismiss();
            })
      ],
      builder: (showcaseContext) {
        if (_isFirstTime && !_hasStartedShowcase) {
          _refresh(() => _showcaseContext = showcaseContext);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refresh(() => _hasStartedShowcase = true);
            ShowCaseWidget.of(_showcaseContext).startShowCase(_showcaseKeys);
          });
        }

        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    final bgImagePath = CommonBox.get('backgroundImage') as String?;
    final availablePages = pages.where((page) => page.displayGetter()).toList();
    if (_index >= availablePages.length) {
      _index = availablePages.length - 1;
    }

    return MScaffold(
      safeArea: false,
      safeBottom: false,
      child: FScaffold(
        contentPad: false,
        content: Container(
          decoration: BoxDecoration(
            image: bgImagePath != null
                ? DecorationImage(
                    image: FileImage(File(bgImagePath)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: IndexedStack(
            index: _index,
            children: availablePages.map((data) {
              final index = availablePages.indexOf(data);
              final page = data.pageGetter();
              return KeyedSubtree(
                key: _pageKeys[index],
                child: page ?? const Empty(),
              );
            }).toList(),
          ),
        ),
        footer: FBottomNavigationBar(
          index: _index,
          onChange: (index) {
            _refresh(() => _index = index);
          },
          children: availablePages.map((data) {
            final color =
                availablePages[_index] == data ? MTheme.primary2 : Colors.grey;
            return ValueListenableBuilder(
                valueListenable: ValueService.hasUpdate,
                builder: (context, hasUpdate, child) {
                  return FBottomNavigationBarItem(
                    label: Text(
                      data.name,
                      style: TextStyle(color: color, fontSize: 10),
                    ),
                    icon: SizedBox(
                      width: 40,
                      child: Stack(
                        children: [
                          Center(
                            child: FaIcon(data.icon, color: color, size: 20),
                          ),
                          if (data.name == '设置' && hasUpdate)
                            Positioned(
                              left: (40 / 2) + 10,
                              child: SizedBox(
                                width: 5,
                                height: 5,
                                child: badge.Badge(),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                });
          }).toList(),
        ),
      ),
    );
  }
}
