import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/data/values.dart';

import '../../data/m_theme.dart';
import '../../entity/soa/course/course_entry.dart';

class HorizontalCourseCard extends StatelessWidget {
  const HorizontalCourseCard(
      {super.key,
      required this.height,
      required this.course,
      required this.isActive,
      required this.isNext});

  final double height;
  final CourseEntry course;
  final bool isActive;
  final bool isNext;

  String formatTimeDifference(TimeOfDay start, TimeOfDay end) {
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    int diffMinutes = (endMinutes - startMinutes).abs(); // 取绝对值，确保正数
    int hours = diffMinutes ~/ 60;
    int minutes = diffMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return "$hours小时$minutes分";
    } else if (hours > 0) {
      return "$hours小时";
    } else {
      return "$minutes分";
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondaryStyle = TextStyle(color: Colors.grey, fontSize: 14);
    final times = <String>[];
    for (final t in Values.courseTableTimes) {
      for (final j in t.split('\n')) {
        times.add(j);
      }
    }
    final time = course.startSection == null || course.endSection == null
        ? Values.courseTableTimes[course.numberOfDay - 1].replaceAll('\n', '-')
        : '${times[course.startSection! - 1]}-${times[course.endSection! - 1]}';
    final startTime = time.split('-').first;
    final [startHour, startMinute] =
        startTime.split(':').map((c) => int.parse(c)).toList();
    final now = DateTime.now();
    final nowTod = TimeOfDay(hour: now.hour, minute: now.minute);
    final startTod = TimeOfDay(hour: startHour, minute: startMinute);
    final diff = formatTimeDifference(startTod, nowTod);

    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.courseName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Text(
                isActive
                    ? '正在上课'
                    : isNext
                        ? '下节课'
                        : '',
                style: TextStyle(
                  color: MTheme.primary2.withValues(
                    alpha: isActive || isNext ? 1 : 0,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      course.teacherName.join('、'),
                      style: secondaryStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AutoSizeText(
                      course.place,
                      style: secondaryStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (!isActive && isNext)
                    Text(
                      '$diff后上课',
                      style: TextStyle(color: MTheme.primary2, fontSize: 12),
                    ),
                  Text(
                    time,
                    style: TextStyle(color: MTheme.primary2, fontSize: 18),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
