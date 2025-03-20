// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ColorModeAdapter extends TypeAdapter<ColorMode> {
  @override
  final int typeId = 32;

  @override
  ColorMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ColorMode.theme;
      case 1:
        return ColorMode.colorful;
      case 2:
        return ColorMode.palette;
      default:
        return ColorMode.theme;
    }
  }

  @override
  void write(BinaryWriter writer, ColorMode obj) {
    switch (obj) {
      case ColorMode.theme:
        writer.writeByte(0);
        break;
      case ColorMode.colorful:
        writer.writeByte(1);
        break;
      case ColorMode.palette:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
