// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PointsDataAdapter extends TypeAdapter<PointsData> {
  @override
  final int typeId = 24;

  @override
  PointsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PointsData(
      totalCredits: fields[0] as double?,
      requiredCoursesCredits: fields[1] as double?,
      averagePoints: fields[2] as double?,
      requiredCoursesPoints: fields[3] as double?,
      degreeCoursesPoints: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PointsData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalCredits)
      ..writeByte(1)
      ..write(obj.requiredCoursesCredits)
      ..writeByte(2)
      ..write(obj.averagePoints)
      ..writeByte(3)
      ..write(obj.requiredCoursesPoints)
      ..writeByte(4)
      ..write(obj.degreeCoursesPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
