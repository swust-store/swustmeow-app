import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'package:swustmeow/components/home/home_ad.dart';
import 'package:swustmeow/components/home/home_announcement.dart';
import 'package:swustmeow/components/home/home_header.dart';
import 'package:swustmeow/components/home/home_news.dart';
import 'package:swustmeow/components/home/home_tool_grid.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/services/boxes/activities_box.dart';
import 'package:swustmeow/services/global_keys.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/services/version_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/widget.dart';

import '../components/utils/back_again_blocker.dart';
import '../data/activities_store.dart';
import '../data/values.dart';
import '../entity/soa/course/courses_container.dart';
import '../services/boxes/course_box.dart';
import '../services/boxes/soa_box.dart';
import '../services/value_service.dart';
import '../utils/courses.dart';
import '../utils/router.dart';
import '../utils/status.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCourseLoading = ValueService.needCheckCourses;
  int _loginRetries = 0;
  List<Map<String, String>> _ads = [];

  @override
  void initState() {
    super.initState();
    ValueService.activities =
        defaultActivities + GlobalService.extraActivities.value;
    _loadActivities();
    _ads = GlobalService.serverInfo?.ads ?? [];
    _reload();
  }

  Future<void> _reload() async {
    if (ValueService.needCheckCourses) {
      await _loadCoursesContainers();
      final service = FlutterBackgroundService();
      service.invoke('duifeneCurrentCourse', {
        'term': ValueService.currentCoursesContainer?.term,
        'entries': (ValueService.currentCoursesContainer?.entries ?? [])
            .map((entry) => entry.toJson())
            .toList()
      });
    }
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  Future<void> _loadCoursesContainers() async {
    bool cacheSuccess = false;
    final cached = _getCachedCoursesContainers();
    if (cached != null && cached.where((c) => c.id == null).isEmpty) {
      cacheSuccess = true;
      final current =
          getCurrentCoursesContainer(ValueService.activities, cached);
      final (today, currentCourse, nextCourse) =
          getCourse(current, current.entries);
      if (today.isEmpty) ValueService.needCheckCourses = false;
      _refresh(() {
        ValueService.coursesContainers = cached;
        ValueService.todayCourses = today;
        ValueService.currentCoursesContainer = current;
        ValueService.currentCourse = currentCourse;
        ValueService.nextCourse = nextCourse;
        _isCourseLoading = false;
      });
    }

    List<CoursesContainer>? sharedCache =
        (CourseBox.get('sharedContainers') as List<dynamic>?)?.cast();
    if (sharedCache != null) {
      _refresh(() {
        ValueService.sharedContainers = sharedCache;
      });
    }

    if (cacheSuccess) return;

    // 无本地缓存，尝试获取
    if (GlobalService.soaService == null) return;
    final res = await GlobalService.soaService!.getCourseTables();

    Future<StatusContainer<String>> reLogin() async {
      if (_loginRetries == 3) {
        _refresh(() => _loginRetries = 0);
        return const StatusContainer(Status.fail, '登录失败，请重新登录');
      }

      _refresh(() => _loginRetries++);

      if (GlobalService.soaService == null) {
        return const StatusContainer(Status.fail, '本地服务未启动，请重启 APP');
      }

      return await GlobalService.soaService!.login();
    }

    if (!mounted) return;
    if (res.status != Status.ok) {
      // 尝试重新登录
      if (res.status == Status.notAuthorized) {
        final result = await reLogin();
        if (!mounted) return;

        if (result.status == Status.ok) {
          final tgc = result.value!;
          await SOABox.put('tgc', tgc);
        } else {
          await GlobalService.soaService?.logout(notify: true);
          if (mounted) {
            pushReplacement(context, const BackAgainBlocker(child: MainPage()));
          }
          return;
        }

        await _loadCoursesContainers();
      } else {
        return;
      }
    }

    if (!mounted) return;
    if (res.value is String) return;

    List<CoursesContainer> containers = (res.value as List<dynamic>).cast();
    final current =
        getCurrentCoursesContainer(ValueService.activities, containers);
    final (today, currentCourse, nextCourse) =
        getCourse(current, current.entries);
    if (today.isEmpty) ValueService.needCheckCourses = false;

    final account = GlobalService.soaService?.currentAccount?.account;
    final sharedContainersResult =
        await SWUSTStoreApiService.getAllSharedCourseTables(account ?? '');
    if (sharedContainersResult.status != Status.ok) {
      if (!mounted) return;
      showErrorToast(context, '获取共享课表失败：${sharedContainersResult.value}');
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
      ValueService.coursesContainers = containers;
      ValueService.todayCourses = today;
      ValueService.currentCoursesContainer = current;
      ValueService.currentCourse = currentCourse;
      ValueService.nextCourse = nextCourse;
      ValueService.sharedContainers = sharedContainers;
      _isCourseLoading = false;
    });
  }

  List<CoursesContainer>? _getCachedCoursesContainers() {
    if (Values.showcaseMode) {
      return ShowcaseValues.coursesContainers;
    }

    List<dynamic>? result = CourseBox.get('courseTables');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  Future<void> _loadActivities() async {
    List<Activity>? extra =
        (ActivitiesBox.get('extraActivities') as List<dynamic>?)?.cast();
    if (extra == null) return;
    _refresh(() => ValueService.activities = defaultActivities + extra);
  }

  @override
  Widget build(BuildContext context) {
    if (!ValueService.checkedUpdate) {
      VersionService.checkUpdate(context);
      ValueService.checkedUpdate = true;
    }

    const padding = 16.0;
    // _reload();

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        SizedBox(
          height: 300,
          child: HomeHeader(
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
            isLoading: _isCourseLoading,
          ),
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
                  if (_ads.isNotEmpty) HomeAd(ads: _ads),
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
