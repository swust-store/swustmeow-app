import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/will_pop_scope_blocker.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/entity/course/courses_container.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../entity/activity.dart';
import '../../entity/course/course_entry.dart';
import '../../../services/box_service.dart';
import '../../../utils/status.dart';
import '../../utils/courses.dart';
import '../../views/main_page.dart';

class CourseTableCard extends StatefulWidget {
  const CourseTableCard({super.key, required this.activities});

  final List<Activity> activities;

  @override
  State<StatefulWidget> createState() => _CourseTableCardState();
}

class _CourseTableCardState extends State<CourseTableCard> {
  List<CoursesContainer> _containers = [];
  CoursesContainer? _currentContainer;
  CourseEntry? _nextCourse;
  bool _isLoading = true;
  int _loginRetries = 0;
  Timer? _timer;

  bool _loadError = false;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadCoursesContainers().then((_) {
      final service = FlutterBackgroundService();
      service.invoke('duifeneCurrentCourse', {
        'term': _currentContainer?.term,
        'entries': (_currentContainer?.entries ?? [])
            .map((entry) => entry.toJson())
            .toList()
      });
    });

    // 每五分钟更新一次卡片
    _timer ??= Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Future<void> _loadCoursesContainers() async {
    final cached = _getCachedCoursesContainers();
    if (cached != null) {
      final current = getCurrentCoursesContainer(widget.activities, cached);
      final (nextCourse, nextCourseTime) =
          _getNextCourse(current, current.entries);
      setState(() {
        _containers = cached;
        _currentContainer = current;
        _nextCourse = nextCourse;
        _isLoading = false;
      });
      return;
    }

    fail(String message) => setState(() {
          _loadError = true;
          _loadErrorMessage = message;
        });

    // 无本地缓存，尝试获取
    final box = BoxService.soaBox;

    if (GlobalService.soaService == null) {
      fail('本地服务未启动，请重启 APP');
      return;
    }
    final res = await GlobalService.soaService!.getCourseTables();

    Future<StatusContainer<String>> reLogin() async {
      final username = box.get('username') as String?;
      final password = box.get('password') as String?;
      if (_loginRetries == 3) {
        setState(() => _loginRetries = 0);
        return const StatusContainer(Status.fail, '登录失败，请重新登录');
      }

      setState(() => _loginRetries++);

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
          fail('${result.value ?? '未知错误'}，请重新登录');
          await GlobalService.soaService?.logout();
          if (mounted) {
            pushReplacement(
                context, const WillPopScopeBlocker(child: MainPage()));
          }
          return;
        }

        await _loadCoursesContainers();
      } else {
        if (context.mounted) {
          fail(res.value);
        }
        return;
      }
    }

    if (!mounted) return;

    if (res.value is String) {
      fail(res.value);
      return;
    }

    List<CoursesContainer> containers = (res.value as List<dynamic>).cast();
    final current = getCurrentCoursesContainer(widget.activities, containers);
    final (nextCourse, nextCourseTime) =
        _getNextCourse(current, current.entries);
    setState(() {
      _containers = containers;
      _currentContainer = current;
      _nextCourse = nextCourse;
      _isLoading = false;
    });
  }

  List<CoursesContainer>? _getCachedCoursesContainers() {
    List<dynamic>? result = BoxService.courseBox.get('courseTables');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  (CourseEntry?, String?) _getNextCourse(
      CoursesContainer current, List<CourseEntry> entries) {
    if (entries.isEmpty) return (null, null);
    final now = DateTime.now();
    final (i, _) = getWeekNum(current.term, now);
    final todayEntries = entries
        .where((entry) =>
            i &&
            !checkIfFinished(current.term, entry, entries) &&
            entry.weekday == now.weekday)
        .toList()
      ..sort((a, b) => a.numberOfDay.compareTo(b.numberOfDay));
    for (int index = 0; index < todayEntries.length; index++) {
      final entry = todayEntries[index];
      final time = Values.courseTableTimes[index];
      final [start, end] = time.split('\n');
      if (timeStringToTimeOfDay(start)
          .isAfter(TimeOfDay(hour: now.hour, minute: now.minute))) {
        return (entry, '$start-$end');
      }
    }
    return (null, null);
  }

  Widget _getChild() {
    final style = TextStyle(color: _loadError ? Colors.red : Colors.grey);
    return SizedBox(
      height: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Divider(),
          Text(
              _loadError
                  ? '错误'
                  : _isLoading
                      ? '加载中'
                      : '下节课',
              style: style.copyWith(fontSize: 16)),
          Skeletonizer(
              enabled: _isLoading && !_loadError,
              effect: Values.skeletonizerEffect,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _loadError
                          ? _loadErrorMessage ?? '未知错误'
                          : (_nextCourse?.courseName ?? '接下来没课啦'),
                      style: style.copyWith(fontSize: 11)),
                  if (!_loadError)
                    Text(
                      _nextCourse?.place ?? '好好休息吧~',
                      style: style.copyWith(fontSize: 10),
                    ),
                ],
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FTappable(
        onPress: () {
          if (!_isLoading && !_loadError) {
            pushTo(
                context,
                CourseTablePage(
                  containers: _containers,
                  currentContainer: _currentContainer!,
                  activities: widget.activities,
                ),
                pushInto: true);
            setState(() {});
          }
        },
        child: FCard(
          image: FIcon(FAssets.icons.bookText),
          title: const Text('课程表'),
          // subtitle: const Column(
          //   children: [
          //     SizedBox(
          //       height: 8,
          //     ),
          //     Text('看看今天有什么课吧~')
          //   ],
          // ),
          child: _getChild(),
        ));
  }
}
