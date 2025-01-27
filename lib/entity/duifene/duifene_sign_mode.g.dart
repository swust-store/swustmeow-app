// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duifene_sign_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DuiFenESignModeAdapter extends TypeAdapter<DuiFenESignMode> {
  @override
  final int typeId = 8;

  @override
  DuiFenESignMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DuiFenESignMode.after;
      case 1:
        return DuiFenESignMode.before;
      case 2:
        return DuiFenESignMode.random;
      default:
        return DuiFenESignMode.after;
    }
  }

  @override
  void write(BinaryWriter writer, DuiFenESignMode obj) {
    switch (obj) {
      case DuiFenESignMode.after:
        writer.writeByte(0);
        break;
      case DuiFenESignMode.before:
        writer.writeByte(1);
        break;
      case DuiFenESignMode.random:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuiFenESignModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
