// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duifene_homework.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuiFenEHomework _$DuiFenEHomeworkFromJson(Map<String, dynamic> json) =>
    DuiFenEHomework(
      course: DuiFenECourse.fromJson(json['course'] as Map<String, dynamic>),
      name: json['name'] as String,
      endTime: DateTime.parse(json['endTime'] as String),
      finished: json['finished'] as bool,
      overdue: json['overdue'] as bool,
    );

Map<String, dynamic> _$DuiFenEHomeworkToJson(DuiFenEHomework instance) =>
    <String, dynamic>{
      'course': instance.course,
      'name': instance.name,
      'endTime': instance.endTime.toIso8601String(),
      'finished': instance.finished,
      'overdue': instance.overdue,
    };
