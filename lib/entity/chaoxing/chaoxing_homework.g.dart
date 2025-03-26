// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chaoxing_homework.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChaoXingHomework _$ChaoXingHomeworkFromJson(Map<String, dynamic> json) =>
    ChaoXingHomework(
      title: json['title'] as String,
      labels:
          (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ChaoXingHomeworkToJson(ChaoXingHomework instance) =>
    <String, dynamic>{
      'title': instance.title,
      'labels': instance.labels,
      'status': instance.status,
    };
