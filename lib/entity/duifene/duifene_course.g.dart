// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duifene_course.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DuiFenECourseAdapter extends TypeAdapter<DuiFenECourse> {
  @override
  final int typeId = 7;

  @override
  DuiFenECourse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DuiFenECourse(
      courseName: fields[0] as String,
      courseId: fields[1] as String,
      tClassId: fields[2] as String,
      courseMatched: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DuiFenECourse obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.courseName)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.tClassId)
      ..writeByte(3)
      ..write(obj.courseMatched);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuiFenECourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuiFenECourse _$DuiFenECourseFromJson(Map<String, dynamic> json) =>
    DuiFenECourse(
      courseName: json['CourseName'] as String,
      courseId: json['CourseID'] as String,
      tClassId: json['TClassID'] as String,
      courseMatched: json['courseMatched'] as String?,
    );

Map<String, dynamic> _$DuiFenECourseToJson(DuiFenECourse instance) =>
    <String, dynamic>{
      'CourseName': instance.courseName,
      'CourseID': instance.courseId,
      'TClassID': instance.tClassId,
      'courseMatched': instance.courseMatched,
    };
