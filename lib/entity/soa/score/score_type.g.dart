// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreTypeAdapter extends TypeAdapter<ScoreType> {
  @override
  final int typeId = 23;

  @override
  ScoreType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScoreType.plan;
      case 1:
        return ScoreType.common;
      case 2:
        return ScoreType.physical;
      default:
        return ScoreType.plan;
    }
  }

  @override
  void write(BinaryWriter writer, ScoreType obj) {
    switch (obj) {
      case ScoreType.plan:
        writer.writeByte(0);
        break;
      case ScoreType.common:
        writer.writeByte(1);
        break;
      case ScoreType.physical:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
