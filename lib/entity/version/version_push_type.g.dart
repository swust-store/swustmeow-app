// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_push_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VersionPushTypeAdapter extends TypeAdapter<VersionPushType> {
  @override
  final int typeId = 27;

  @override
  VersionPushType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VersionPushType.minor;
      case 1:
        return VersionPushType.major;
      default:
        return VersionPushType.minor;
    }
  }

  @override
  void write(BinaryWriter writer, VersionPushType obj) {
    switch (obj) {
      case VersionPushType.minor:
        writer.writeByte(0);
        break;
      case VersionPushType.major:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VersionPushTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
