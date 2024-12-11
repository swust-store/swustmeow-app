import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'course_entry.dart';

part 'course_table_entity.g.dart';

@JsonSerializable()
class CourseTableEntity {
  CourseTableEntity({required this.entries});

  List<CourseEntry> entries;

  factory CourseTableEntity.fromEntriesList(List<dynamic> value) {
    final List<CourseEntry> entries = [];
    for (final Map<String, dynamic> entry in value) {
      final entity = CourseEntry.fromJson(entry);
      entries.add(entity);
    }
    return CourseTableEntity(entries: entries);
  }

  factory CourseTableEntity.fromString(String value) {
    final data = json.decode(value) as Map<String, dynamic>;
    return CourseTableEntity.fromJson(data);
  }

  factory CourseTableEntity.fromJson(Map<String, dynamic> json) =>
      _$CourseTableEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CourseTableEntityToJson(this);
}
