// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseScoreAdapter extends TypeAdapter<CourseScore> {
  @override
  final int typeId = 20;

  @override
  CourseScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseScore(
      courseName: fields[0] as String,
      courseId: fields[1] as String,
      credit: fields[2] as double,
      courseType: fields[3] as String,
      formalScore: fields[4] as String,
      resitScore: fields[5] as String,
      points: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CourseScore obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.courseName)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.credit)
      ..writeByte(3)
      ..write(obj.courseType)
      ..writeByte(4)
      ..write(obj.formalScore)
      ..writeByte(5)
      ..write(obj.resitScore)
      ..writeByte(6)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
