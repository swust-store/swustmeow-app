import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../entity/course_entry.dart';
import '../../services/box_service.dart';
import '../../utils/common.dart';
import '../../utils/status.dart';
import '../../utils/user.dart';

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

    // 无本地缓存，尝试获取
    final prefs = await SharedPreferences.getInstance();
    final res = await getCourseEntries();

    Future<StatusContainer<String>?> reLogin() async {
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      if (_loginRetries == 3) {
        setState(() => _loginRetries = 0);
        return null;
      }

      setState(() => _loginRetries++);
      return await performLogin(username, password);
    }

    fail(String message) => setState(() {
          _loadError = true;
          _loadErrorMessage = message;
        });

    if (res.status != Status.ok) {
      // 尝试重新登录
      if (res.status == Status.notAuthorized) {
        final result = await reLogin();
        if (result == null) {
          if (context.mounted) {
            fail('登录失败，请重新登录');
            await logOut(context);
          }
          return;
        }

        if (result.status == Status.ok) {
          final tgc = result.value!;
          await prefs.setString('TGC', tgc);
        }
        await _loadCourseEntries();
      } else {
        if (context.mounted) {
          fail(res.value);
        }
        return;
      }
    }

    if (res.value is String) {
      if (context.mounted) {
        fail(res.value);
      }
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
    final todayEntries = entries
        .where((entry) => entry.getIsActive())
        .where((entry) => entry.weekday == Values.now.weekday)
        .toList()
      ..sort((a, b) => a.numberOfDay.compareTo(b.numberOfDay));
    for (int index = 0; index < todayEntries.length; index++) {
      final entry = todayEntries[index];
      final time = Values.courseTableTimes[index];
      final [start, end] = time.split('\n');
      final now = Values.now;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _loadError
                          ? '无法加载课程表'
                          : (_nextCourse?.courseName ?? '接下来没课啦'),
                      style: style.copyWith(fontSize: 12)),
                  Text(
                    _loadError
                        ? _loadErrorMessage ?? '未知错误'
                        : (_nextCourse?.place ?? '好好休息吧~'),
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
        onPress: () {
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
          subtitle: const Text('看看今天有什么课吧~'),
          style: widget.cardStyle,
          child: _getChild(),
        ));
  }
}
