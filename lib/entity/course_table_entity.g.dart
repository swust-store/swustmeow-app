// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_table_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseTableEntity _$CourseTableEntityFromJson(Map<String, dynamic> json) =>
    CourseTableEntity(
      entries: (json['entries'] as List<dynamic>)
          .map(
              (e) => CourseTableEntryEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      experiments: (json['experiments'] as List<dynamic>)
          .map(
              (e) => CourseTableEntryEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseTableEntityToJson(CourseTableEntity instance) =>
    <String, dynamic>{
      'entries': instance.entries,
      'experiments': instance.experiments,
    };
