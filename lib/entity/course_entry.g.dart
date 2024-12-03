// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseEntry _$CourseEntryFromJson(Map<String, dynamic> json) => CourseEntry(
      courseName: json['courseName'] as String,
      teacherName: (json['teacherName'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startWeek: (json['startWeek'] as num).toInt(),
      endWeek: (json['endWeek'] as num).toInt(),
      place: json['place'] as String,
      weekday: (json['weekday'] as num).toInt(),
      numberOfDay: (json['numberOfDay'] as num).toInt(),
      color: (json['color'] as num?)?.toInt() ?? 0xFF000000,
    );

Map<String, dynamic> _$CourseEntryToJson(CourseEntry instance) =>
    <String, dynamic>{
      'courseName': instance.courseName,
      'teacherName': instance.teacherName,
      'startWeek': instance.startWeek,
      'endWeek': instance.endWeek,
      'place': instance.place,
      'weekday': instance.weekday,
      'numberOfDay': instance.numberOfDay,
      'color': instance.color,
    };
