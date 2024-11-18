import 'package:flutter/material.dart';

class CourseTableEntryEntity {
  CourseTableEntryEntity(
      {required this.courseName,
      required this.teacherName,
      required this.startWeek,
      required this.endWeek,
      required this.place,
      required this.weekday,
      required this.numberOfDay,
      this.color = Colors.black});

  final String courseName;
  final String teacherName;
  final int startWeek;
  final int endWeek;
  final String place;
  final int weekday;
  final int numberOfDay;
  Color color;
}
