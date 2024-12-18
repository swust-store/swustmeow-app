import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../entity/course_entry.dart';
import '../../services/box_service.dart';

class CourseTableCard extends StatefulWidget {
  const CourseTableCard({super.key, required this.cardStyle});

  final FCardStyle cardStyle;

  @override
  State<StatefulWidget> createState() => _CourseTableCardState();
}

class _CourseTableCardState extends State<CourseTableCard> {
  List<CourseEntry>? entries;
  CourseEntry? _nextCourse;
  String? _nextCourseTime;
  bool _loadingNextCourse = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  List<CourseEntry>? _getCachedCourseEntries() {
    List<dynamic>? result =
        BoxService.courseEntryListBox.get('courseTableEntries');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  void _loadEntries() {
    final cached = _getCachedCourseEntries();
    if (cached != null) {
      final (nextCourse, nextCourseTime) = _getNextCourse(cached);
      print(nextCourse?.courseName);
      print(nextCourse?.weekday);
      setState(() {
        _nextCourse = nextCourse;
        _nextCourseTime = nextCourseTime;
        _loadingNextCourse = false;
        entries = cached;
      });
    }
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
    const style = TextStyle(color: Colors.grey);
    return SizedBox(
      height: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          const Divider(),
          Text('下节课', style: style.copyWith(fontSize: 16)),
          Skeletonizer(
              enabled: _loadingNextCourse,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   _nextCourseTime ?? '接下来没课啦',
                  //   style: style.copyWith(fontSize: 12),
                  // ),
                  Text(_nextCourse?.courseName ?? '接下来没课啦',
                      style: style.copyWith(fontSize: 12)),
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
        onPress: () {
          pushTo(
              context,
              CourseTablePage(
                entries: entries,
              ));
          setState(() {});
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
