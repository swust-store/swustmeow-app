import 'package:json_annotation/json_annotation.dart';

part 'course_entry.g.dart';

@JsonSerializable()
class CourseEntry {
  CourseEntry(
      {required this.courseName,
      required this.teacherName,
      required this.startWeek,
      required this.endWeek,
      required this.place,
      required this.weekday,
      required this.numberOfDay,
      this.color = 0xFF000000});

  final String courseName;
  final List<String> teacherName;
  final int startWeek;
  final int endWeek;
  final String place;
  final int weekday;
  final int numberOfDay;
  int color;

  factory CourseEntry.fromJson(Map<String, dynamic> json) =>
      _$CourseEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseEntryToJson(this);
}
