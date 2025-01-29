import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miaomiaoswust/entity/course/course_type.dart';

import '../../utils/color.dart';

part 'course_entry.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class CourseEntry {
  CourseEntry({
    required this.courseName,
    required this.teacherName,
    required this.startWeek,
    required this.endWeek,
    required this.place,
    required this.weekday,
    required this.numberOfDay,
    this.color = 0xFF000000,
  }) {
    if (color == 0xFF000000) {
      int color =
          generateColorFromString(courseName, minBrightness: 0.5).toInt();
      this.color = color;
    }
  }

  @HiveField(0)
  final String courseName;

  @HiveField(1)
  final List<String> teacherName;

  @HiveField(2)
  final int startWeek;

  @HiveField(3)
  final int endWeek;

  @HiveField(4)
  final String place;

  @HiveField(5)
  final int weekday;

  @HiveField(6)
  final int numberOfDay;

  @HiveField(7)
  int color;

  factory CourseEntry.fromJson(Map<String, dynamic> json) =>
      _$CourseEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseEntryToJson(this);
}
