// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerInfoAdapter extends TypeAdapter<ServerInfo> {
  @override
  final int typeId = 4;

  @override
  ServerInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerInfo(
      pyServerUrl: fields[0] as String,
      libraryServerUrl: fields[1] as String,
      activitiesUrl: fields[2] as String,
      termDatesUrl: fields[3] as String,
      announcement: fields[4] as String,
      ads: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      qun: (fields[6] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      news: (fields[7] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<dynamic>())),
      changelogUrl: fields[8] as String,
      agreements: (fields[9] as Map).cast<String, dynamic>(),
      iosDistributionUrl: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ServerInfo obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.pyServerUrl)
      ..writeByte(1)
      ..write(obj.libraryServerUrl)
      ..writeByte(2)
      ..write(obj.activitiesUrl)
      ..writeByte(3)
      ..write(obj.termDatesUrl)
      ..writeByte(4)
      ..write(obj.announcement)
      ..writeByte(5)
      ..write(obj.ads)
      ..writeByte(6)
      ..write(obj.qun)
      ..writeByte(7)
      ..write(obj.news)
      ..writeByte(8)
      ..write(obj.changelogUrl)
      ..writeByte(9)
      ..write(obj.agreements)
      ..writeByte(10)
      ..write(obj.iosDistributionUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
