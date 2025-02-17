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
    this.startSection,
    this.endSection,
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

  /// 已被弃用，结果是错误的
  @HiveField(6)
  final int numberOfDay;

  @HiveField(7)
  int color;

  @HiveField(8)
  final String displayName;

  /// 开始节数（范围 1-12）
  @HiveField(9)
  final int? startSection;

  /// 结束节数（范围 1-12）
  @HiveField(10)
  final int? endSection;

  factory CourseEntry.fromJson(Map<String, dynamic> json) =>
      _$CourseEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseEntryToJson(this);
}
