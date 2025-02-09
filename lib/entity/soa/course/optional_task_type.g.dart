// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optional_task_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OptionalTaskTypeAdapter extends TypeAdapter<OptionalTaskType> {
  @override
  final int typeId = 14;

  @override
  OptionalTaskType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OptionalTaskType.commonTask;
      case 1:
        return OptionalTaskType.sportTask;
      default:
        return OptionalTaskType.commonTask;
    }
  }

  @override
  void write(BinaryWriter writer, OptionalTaskType obj) {
    switch (obj) {
      case OptionalTaskType.commonTask:
        writer.writeByte(0);
        break;
      case OptionalTaskType.sportTask:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptionalTaskTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
