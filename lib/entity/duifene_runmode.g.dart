// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duifene_runmode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DuiFenERunModeAdapter extends TypeAdapter<DuiFenERunMode> {
  @override
  final int typeId = 6;

  @override
  DuiFenERunMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DuiFenERunMode.foreground;
      case 1:
        return DuiFenERunMode.background;
      default:
        return DuiFenERunMode.foreground;
    }
  }

  @override
  void write(BinaryWriter writer, DuiFenERunMode obj) {
    switch (obj) {
      case DuiFenERunMode.foreground:
        writer.writeByte(0);
        break;
      case DuiFenERunMode.background:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuiFenERunModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
