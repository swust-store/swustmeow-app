// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VersionInfoAdapter extends TypeAdapter<VersionInfo> {
  @override
  final int typeId = 25;

  @override
  VersionInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VersionInfo(
      version: fields[0] as Version,
      releaseDate: fields[1] as DateTime,
      pushType: fields[2] as VersionPushType,
      distributionUrl: fields[3] as String,
      changes: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, VersionInfo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.releaseDate)
      ..writeByte(2)
      ..write(obj.pushType)
      ..writeByte(3)
      ..write(obj.distributionUrl)
      ..writeByte(4)
      ..write(obj.changes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VersionInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
