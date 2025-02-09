// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseTypeAdapter extends TypeAdapter<CourseType> {
  @override
  final int typeId = 9;

  @override
  CourseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CourseType.normal;
      case 1:
        return CourseType.optional;
      default:
        return CourseType.normal;
    }
  }

  @override
  void write(BinaryWriter writer, CourseType obj) {
    switch (obj) {
      case CourseType.normal:
        writer.writeByte(0);
        break;
      case CourseType.optional:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
