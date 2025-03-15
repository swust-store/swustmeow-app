// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duifene_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuiFenETest _$DuiFenETestFromJson(Map<String, dynamic> json) => DuiFenETest(
      course: DuiFenECourse.fromJson(json['course'] as Map<String, dynamic>),
      name: json['name'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      beginTime: json['beginTime'] == null
          ? null
          : DateTime.parse(json['beginTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      submitTime: json['submitTime'] == null
          ? null
          : DateTime.parse(json['submitTime'] as String),
      limitMinutes: (json['limitMinutes'] as num).toInt(),
      creatorName: json['creatorName'] as String,
      score: (json['score'] as num).toInt(),
      finished: json['finished'] as bool,
      overdue: json['overdue'] as bool,
    );

Map<String, dynamic> _$DuiFenETestToJson(DuiFenETest instance) =>
    <String, dynamic>{
      'course': instance.course,
      'name': instance.name,
      'beginTime': instance.beginTime?.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'finished': instance.finished,
      'createTime': instance.createTime.toIso8601String(),
      'submitTime': instance.submitTime?.toIso8601String(),
      'limitMinutes': instance.limitMinutes,
      'creatorName': instance.creatorName,
      'score': instance.score,
      'overdue': instance.overdue,
    };
