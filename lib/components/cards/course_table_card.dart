import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../entity/course_entry.dart';
import '../../../services/box_service.dart';
import '../../../utils/common.dart';
import '../../../utils/status.dart';

class CourseTableCard extends StatefulWidget {
  const CourseTableCard({super.key, required this.cardStyle});

  final FCardStyle cardStyle;

  @override
  State<StatefulWidget> createState() => _CourseTableCardState();
}

class _CourseTableCardState extends State<CourseTableCard> {
  List<CourseEntry>? _entries;
  CourseEntry? _nextCourse;
  bool _isLoading = true;
  int _loginRetries = 0;

  bool _loadError = false;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourseEntries();
  }

  Future<void> _loadCourseEntries() async {
    final cached = _getCachedCourseEntries();
    if (cached != null) {
      final (nextCourse, nextCourseTime) = _getNextCourse(cached);
      setState(() {
        _entries = cached;
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
    final prefs = await SharedPreferences.getInstance();

    if (GlobalService.soaService == null) {
      fail('本地服务未启动，请重启 APP');
      return;
    }
    final res = await GlobalService.soaService!.getCourseEntries();

    Future<StatusContainer<String>> reLogin() async {
      final username = prefs.getString('soaUsername');
      final password = prefs.getString('soaPassword');
      if (_loginRetries == 3) {
        setState(() => _loginRetries = 0);
        return const StatusContainer(Status.fail, '登录失败，请重新登录');
      }

      setState(() => _loginRetries++);

      if (GlobalService.soaService == null) {
        return const StatusContainer(Status.fail, '本地服务未启动，请重启 APP');
      }

      return await GlobalService.soaService!.login(username, password);
    }

    if (!mounted) return;
    if (res.status != Status.ok) {
      // 尝试重新登录
      if (res.status == Status.notAuthorized) {
        final result = await reLogin();
        if (!mounted) return;

        if (result.status == Status.ok) {
          final tgc = result.value!;
          await prefs.setString('soaTGC', tgc);
        } else {
          fail(result.value ?? '未知错误');
          await logOut(context);
          return;
        }

        await _loadCourseEntries();
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

    List<CourseEntry> entries = (res.value as List<dynamic>).cast();
    final (nextCourse, nextCourseTime) = _getNextCourse(entries);
    setState(() {
      _entries = entries;
      _nextCourse = nextCourse;
      _isLoading = false;
    });
  }

  List<CourseEntry>? _getCachedCourseEntries() {
    List<dynamic>? result =
        BoxService.courseEntryListBox.get('courseTableEntries');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  (CourseEntry?, String?) _getNextCourse(List<CourseEntry> entries) {
    if (entries.isEmpty) return (null, null);
    final now = DateTime.now();
    final todayEntries = entries
        .where((entry) => !entry.checkIfFinished(entries))
        .where((entry) => entry.weekday == now.weekday)
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
          const SizedBox(
            height: 8,
          ),
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
    return Clickable(
        onClick: () {
          if (!_isLoading && !_loadError) {
            pushTo(
                context,
                CourseTablePage(
                  entries: _entries ?? [],
                ));
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
          style: widget.cardStyle,
          child: _getChild(),
        ));
  }
}
