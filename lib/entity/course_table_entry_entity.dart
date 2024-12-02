import 'package:json_annotation/json_annotation.dart';

part 'course_table_entry_entity.g.dart';

@JsonSerializable()
class CourseTableEntryEntity {
  CourseTableEntryEntity(
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

  factory CourseTableEntryEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseTableEntryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseTableEntryEntityToJson(this);
}
