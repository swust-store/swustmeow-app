import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:swustmeow/components/home/home_announcement.dart';
import 'package:swustmeow/components/home/home_header.dart';
import 'package:swustmeow/components/home/home_tool_grid.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';

import '../components/utils/will_pop_scope_blocker.dart';
import '../data/activities_store.dart';
import '../data/values.dart';
import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/courses_container.dart';
import '../services/value_service.dart';
import '../utils/courses.dart';
import '../utils/router.dart';
import '../utils/status.dart';
import '../utils/time.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCourseLoading = ValueService.needCheckCourses;
  int _loginRetries = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    ValueService.activities =
        defaultActivities + GlobalService.extraActivities.value;
    await _loadActivities();

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
    final cached = _getCachedCoursesContainers();
    if (cached != null) {
      final current =
          getCurrentCoursesContainer(ValueService.activities, cached);
      final (today, currentCourse, nextCourse) =
          _getCourse(current, current.entries);
      if (today.isEmpty) ValueService.needCheckCourses = false;
      _refresh(() {
        ValueService.coursesContainers = cached;
        ValueService.todayCourses = today;
        ValueService.currentCoursesContainer = current;
        ValueService.currentCourse = currentCourse;
        ValueService.nextCourse = nextCourse;
        _isCourseLoading = false;
      });
      return;
    }

    // 无本地缓存，尝试获取
    final box = BoxService.soaBox;
    if (GlobalService.soaService == null) return;
    final res = await GlobalService.soaService!.getCourseTables();

    Future<StatusContainer<String>> reLogin() async {
      final username = box.get('username') as String?;
      final password = box.get('password') as String?;
      if (_loginRetries == 3) {
        _refresh(() => _loginRetries = 0);
        return const StatusContainer(Status.fail, '登录失败，请重新登录');
      }

      _refresh(() => _loginRetries++);

      if (GlobalService.soaService == null) {
        return const StatusContainer(Status.fail, '本地服务未启动，请重启 APP');
      }

      return await GlobalService.soaService!
          .login(username: username, password: password);
    }

    if (!mounted) return;
    if (res.status != Status.ok) {
      // 尝试重新登录
      if (res.status == Status.notAuthorized) {
        final result = await reLogin();
        if (!mounted) return;

        if (result.status == Status.ok) {
          final tgc = result.value!;
          await box.put('tgc', tgc);
        } else {
          await GlobalService.soaService?.logout();
          if (mounted) {
            pushReplacement(
                context, const WillPopScopeBlocker(child: MainPage()));
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
        _getCourse(current, current.entries);
    if (today.isEmpty) ValueService.needCheckCourses = false;
    _refresh(() {
      ValueService.coursesContainers = containers;
      ValueService.todayCourses = today;
      ValueService.currentCoursesContainer = current;
      ValueService.currentCourse = currentCourse;
      ValueService.nextCourse = nextCourse;
      _isCourseLoading = false;
    });
  }

  List<CoursesContainer>? _getCachedCoursesContainers() {
    List<dynamic>? result = BoxService.courseBox.get('courseTables');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  /// 获取今天的所有课程、当前的课程以及下节课
  ///
  /// 返回 (今天的所有课程列表, 当前课程, 下节课程)
  (List<CourseEntry>, CourseEntry?, CourseEntry?) _getCourse(
      CoursesContainer current, List<CourseEntry> entries) {
    if (entries.isEmpty) return ([], null, null);
    final now = DateTime.now();
    final (i, _) = getWeekNum(current.term, now);
    final todayEntries = entries
        .where((entry) =>
            i &&
            !checkIfFinished(current.term, entry, entries) &&
            entry.weekday == now.weekday)
        .toList()
      ..sort((a, b) => a.numberOfDay.compareTo(b.numberOfDay));

    CourseEntry? currentCourse;
    CourseEntry? nextCourse;

    for (int index = 0; index < todayEntries.length; index++) {
      final entry = todayEntries[index];
      final time = Values.courseTableTimes[index];
      final [start, end] = time.split('\n');
      final startTime = timeStringToTimeOfDay(start);
      final endTime = timeStringToTimeOfDay(end);
      final nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

      if (startTime > nowTime) {
        nextCourse = entry;
      }

      if (startTime >= nowTime && endTime <= nowTime) {
        currentCourse = entry;
      }
    }

    return (todayEntries, currentCourse, nextCourse);
  }

  Future<void> _loadActivities() async {
    final box = BoxService.activitiesBox;
    List<Activity>? extra =
        (box.get('extraActivities') as List<dynamic>?)?.cast();
    if (extra == null) return;
    _refresh(() => ValueService.activities = defaultActivities + extra);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    const padding = 16.0;
    _reload();

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: HomeHeader(
                refresh: () => SystemChrome.setSystemUIOverlayStyle(
                    SystemUiOverlayStyle.light),
                activities: ValueService.activities,
                containers: ValueService.coursesContainers,
                currentCourseContainer: ValueService.currentCoursesContainer,
                todayCourses: ValueService.todayCourses,
                nextCourse: ValueService.nextCourse,
                currentCourse: ValueService.currentCourse,
                isLoading: _isCourseLoading),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeToolGrid(padding: padding),
                HomeAnnouncement(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
