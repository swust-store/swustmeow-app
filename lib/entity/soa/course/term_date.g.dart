// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term_date.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TermDateAdapter extends TypeAdapter<TermDate> {
  @override
  final int typeId = 11;

  @override
  TermDate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TermDate(
      start: fields[0] as DateTime,
      end: fields[1] as DateTime,
      weeks: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TermDate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.weeks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermDateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
