// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apartment_student_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApartmentStudentInfoAdapter extends TypeAdapter<ApartmentStudentInfo> {
  @override
  final int typeId = 22;

  @override
  ApartmentStudentInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApartmentStudentInfo(
      roomName: fields[0] as String,
      bed: fields[1] as int,
      className: fields[2] as String,
      facultyName: fields[3] as String,
      grade: fields[4] as int,
      isCheckIn: fields[5] as bool,
      realName: fields[6] as String,
      studentNumber: fields[7] as String,
      studentTypeName: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ApartmentStudentInfo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.roomName)
      ..writeByte(1)
      ..write(obj.bed)
      ..writeByte(2)
      ..write(obj.className)
      ..writeByte(3)
      ..write(obj.facultyName)
      ..writeByte(4)
      ..write(obj.grade)
      ..writeByte(5)
      ..write(obj.isCheckIn)
      ..writeByte(6)
      ..write(obj.realName)
      ..writeByte(7)
      ..write(obj.studentNumber)
      ..writeByte(8)
      ..write(obj.studentTypeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApartmentStudentInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
