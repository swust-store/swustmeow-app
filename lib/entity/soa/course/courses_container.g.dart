// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courses_container.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoursesContainerAdapter extends TypeAdapter<CoursesContainer> {
  @override
  final int typeId = 10;

  @override
  CoursesContainer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoursesContainer(
      type: fields[0] as CourseType,
      term: fields[1] as String,
      entries: (fields[2] as List).cast<CourseEntry>(),
      id: fields[3] as String?,
      sharerId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CoursesContainer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.term)
      ..writeByte(2)
      ..write(obj.entries)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.sharerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoursesContainerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
