import 'package:json_annotation/json_annotation.dart';

import 'course_table_entry_entity.dart';

part 'course_table_entity.g.dart';

@JsonSerializable()
class CourseTableEntity {
  CourseTableEntity({required this.entries, required this.experiments});

  List<CourseTableEntryEntity> entries;
  List<CourseTableEntryEntity> experiments;

  factory CourseTableEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseTableEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseTableEntityToJson(this);
}
