import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/course_table_entity.dart';
import 'package:miaomiaoswust/utils/color.dart';
import 'package:miaomiaoswust/utils/text.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/values.dart';

class CourseTable extends StatefulWidget {
  const CourseTable({required this.entity, super.key});

  final CourseTableEntity entity;

  @override
  State<StatefulWidget> createState() => _CourseTableState();
}

class _CourseTableState extends State<CourseTable> {
  @override
  Widget build(BuildContext context) {
    _generateRandomColors();
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            _buildHeaderRow(),
            ...List.generate(6, (index) => Expanded(child: _buildRow(index)))
          ],
        ));
  }

  Future<void> _generateRandomColors() async {
    final map = {};
    final CourseTableEntity updatedEntity = widget.entity;
    for (final entry in updatedEntity.entries) {
      if (entry.color != 0xFF000000) continue;

      if (map.keys.contains(entry.courseName)) {
        entry.color = map[entry.courseName];
        continue;
      }
      int color;
      while (true) {
        color = randomColor();
        if (Color(color).computeLuminance() < 0.5) break;
      }
      entry.color = color;
      map[entry.courseName] = color;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'courseTableEntity', json.encode(updatedEntity.toJson()));
  }

  Widget _buildHeaderRow() {
    final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final time = DateTime.now();
    getTextStyle(int index) => TextStyle(
        fontSize: 10,
        color: time.weekday == index + 1
            ? Colors.lightBlue
            : context.theme.colorScheme.primary);
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            '${getWeekNumber().toString().padLeft(2, '0')}周',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        ...List.generate(
            days.length,
            (index) => Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(days[index], style: getTextStyle(index)),
                        Text(
                          '${time.month}/${time.day + index}',
                          style: getTextStyle(index),
                        )
                      ],
                    ),
                  ),
                )),
      ],
    );
  }

  Widget _buildRow(int rowIndex) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRow(rowIndex + 1, Values.courseTableTimes[rowIndex]),
          ...List.generate(
              7,
              (dayIndex) =>
                  Expanded(child: _buildCourseCard(dayIndex, rowIndex)))
        ],
      );

  Widget _buildTimeRow(int num, String time) {
    const splitPattern = ':';
    final splitRes = time.split('\n');
    final inRange =
        isHourMinuteInRange(null, splitRes[0], splitRes[1], splitPattern);
    final style = TextStyle(
        color: inRange ? Colors.lightBlue : context.theme.colorScheme.primary);
    return SizedBox(
      width: 34,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
            ),
            Text(num.toString(),
                textAlign: TextAlign.center,
                style: style.copyWith(fontSize: 10)),
            Text(
              time,
              textAlign: TextAlign.center,
              style: style.copyWith(fontSize: 8),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(int dayIndex, int rowIndex) {
    final matched = widget.entity.entries.where((entry) =>
        entry.weekday == dayIndex + 1 && entry.numberOfDay == rowIndex + 1);
    final weekNumber = getWeekNumber();
    if (matched.isNotEmpty) {
      final first = matched.first;
      return Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: weekNumber >= first.startWeek && weekNumber <= first.endWeek
                ? Color(first.color)
                : Colors.grey[300],
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overflowed(first.courseName, 3 * 3),
                style: const TextStyle(
                    color: Colors.white,
                    height: 0,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                    wordSpacing: 0),
              ),
              Text(
                overflowed('@${first.place}', 3 * 3),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    height: 0,
                    fontSize: 10,
                    letterSpacing: 0,
                    wordSpacing: 0),
              ),
            ],
          ));
    }
    return Container();
  }
}
