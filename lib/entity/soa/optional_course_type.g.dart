// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optional_course_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OptionalCourseTypeAdapter extends TypeAdapter<OptionalCourseType> {
  @override
  final int typeId = 13;

  @override
  OptionalCourseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OptionalCourseType.internetGeneralCourse;
      case 1:
        return OptionalCourseType.qualityOptionalCourse;
      case 2:
        return OptionalCourseType.unknown;
      default:
        return OptionalCourseType.internetGeneralCourse;
    }
  }

  @override
  void write(BinaryWriter writer, OptionalCourseType obj) {
    switch (obj) {
      case OptionalCourseType.internetGeneralCourse:
        writer.writeByte(0);
        break;
      case OptionalCourseType.qualityOptionalCourse:
        writer.writeByte(1);
        break;
      case OptionalCourseType.unknown:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptionalCourseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
