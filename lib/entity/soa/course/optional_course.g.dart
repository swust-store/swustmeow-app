// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optional_course.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OptionalCourseAdapter extends TypeAdapter<OptionalCourse> {
  @override
  final int typeId = 12;

  @override
  OptionalCourse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OptionalCourse(
      cid: fields[0] as String,
      name: fields[1] as String,
      credit: fields[2] as double,
      taskType: fields[3] as OptionalTaskType,
      courseType: fields[4] as OptionalCourseType,
    );
  }

  @override
  void write(BinaryWriter writer, OptionalCourse obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.credit)
      ..writeByte(3)
      ..write(obj.taskType)
      ..writeByte(4)
      ..write(obj.courseType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptionalCourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
