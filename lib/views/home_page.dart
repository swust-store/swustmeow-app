import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'package:swustmeow/components/home/home_announcement.dart';
import 'package:swustmeow/components/home/home_header.dart';
import 'package:swustmeow/components/home/home_news.dart';
import 'package:swustmeow/components/home/home_tool_grid.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/global_keys.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/version_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/widget.dart';

import '../data/activities_store.dart';
import '../data/values.dart';
import '../entity/activity.dart';
import '../entity/soa/course/courses_container.dart';
import '../services/boxes/activities_box.dart';
import '../services/boxes/course_box.dart';
import '../services/value_service.dart';
import '../utils/courses.dart';
import '../utils/status.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    ValueService.activities =
        defaultActivities + GlobalService.extraActivities.value;
    _loadActivities();
    if (!Values.showcaseMode) {
      _reload();
    } else {
      ValueService.isCourseLoading.value = false;
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

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
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
      showErrorToast(res.message ?? res.value ?? '未知错误，请重试');
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

  @override
  Widget build(BuildContext context) {
    if (!ValueService.checkedUpdate) {
      VersionService.checkUpdate(context);
      ValueService.checkedUpdate = true;
    }

    const padding = 16.0;

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        SizedBox(
          child: ValueListenableBuilder(
              valueListenable: ValueService.isCourseLoading,
              builder: (context, isCourseLoading, child) {
                return HomeHeader(
                  activities: ValueService.activities,
                  containers: !Values.showcaseMode
                      ? ValueService.coursesContainers
                      : ShowcaseValues.coursesContainers,
                  currentCourseContainer: !Values.showcaseMode
                      ? ValueService.currentCoursesContainer
                      : ShowcaseValues.coursesContainers.first,
                  todayCourses: ValueService.todayCourses,
                  nextCourse: ValueService.nextCourse,
                  currentCourse: ValueService.currentCourse,
                  isLoading: isCourseLoading,
                  onRefresh: () async {
                    await _reload(force: true);
                  },
                );
              }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SizedBox(height: 8),
              buildShowcaseWidget(
                key: GlobalKeys.showcaseToolGridKey,
                title: '工具栏',
                description: '一键直达，快速访问。',
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                child: HomeToolGrid(padding: padding),
              ),
              SizedBox(height: 8),
              ...joinGap(
                gap: 12,
                axis: Axis.vertical,
                widgets: [
                  // if (_ads.isNotEmpty) HomeAd(ads: _ads),
                  HomeAnnouncement(),
                  HomeNews(),
                ],
              ),
              SizedBox(height: 90),
            ],
          ),
        ),
      ],
    );
  }
}
