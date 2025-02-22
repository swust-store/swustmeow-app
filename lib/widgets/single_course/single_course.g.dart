// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleCourse _$SingleCourseFromJson(Map<String, dynamic> json) => SingleCourse(
      name: json['name'] as String,
      place: json['place'] as String,
      time: json['time'] as String,
      diff: json['diff'] as String? ?? '',
    );

Map<String, dynamic> _$SingleCourseToJson(SingleCourse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'place': instance.place,
      'time': instance.time,
      'diff': instance.diff,
    };
