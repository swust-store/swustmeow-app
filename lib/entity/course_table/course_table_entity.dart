import 'package:json_annotation/json_annotation.dart';

import 'course_entry.dart';

part 'course_table_entity.g.dart';

@JsonSerializable()
class CourseTableEntity {
  CourseTableEntity({required this.entries});

  List<CourseEntry> entries;

  factory CourseTableEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseTableEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseTableEntityToJson(this);
}
