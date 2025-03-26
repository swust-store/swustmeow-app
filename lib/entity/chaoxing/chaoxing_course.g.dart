// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chaoxing_course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChaoXingCourse _$ChaoXingCourseFromJson(Map<String, dynamic> json) =>
    ChaoXingCourse(
      courseName: json['course_name'] as String,
      teacherName: json['teacher_name'] as String,
      courseId: (json['course_id'] as num).toInt(),
      classId: (json['class_id'] as num).toInt(),
      cpi: (json['cpi'] as num).toInt(),
    );

Map<String, dynamic> _$ChaoXingCourseToJson(ChaoXingCourse instance) =>
    <String, dynamic>{
      'course_name': instance.courseName,
      'teacher_name': instance.teacherName,
      'course_id': instance.courseId,
      'class_id': instance.classId,
      'cpi': instance.cpi,
    };
