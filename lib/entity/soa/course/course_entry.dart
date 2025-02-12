import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../utils/color.dart';

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
    required this.displayName,
  }) {
    if (color == 0xFF000000) {
      gen([int? salt]) {
        int color = generateColorFromString(
                courseName + (salt == null ? '' : '$salt'),
                minBrightness: 0.5,
                saturationFactor: 0.7)
            .toInt();
        this.color = color;
      }

      int times = 0;
      gen();

      while (Color(color).computeLuminance() > 0.7) {
        gen(times);
        times++;
      }
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

  @HiveField(8)
  final String displayName;

  factory CourseEntry.fromJson(Map<String, dynamic> json) =>
      _$CourseEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseEntryToJson(this);
}
