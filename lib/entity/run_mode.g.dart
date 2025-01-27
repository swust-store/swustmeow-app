// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RunModeAdapter extends TypeAdapter<RunMode> {
  @override
  final int typeId = 6;

  @override
  RunMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RunMode.foreground;
      case 1:
        return RunMode.background;
      default:
        return RunMode.foreground;
    }
  }

  @override
  void write(BinaryWriter writer, RunMode obj) {
    switch (obj) {
      case RunMode.foreground:
        writer.writeByte(0);
        break;
      case RunMode.background:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
