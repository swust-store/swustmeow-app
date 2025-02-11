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
      backendApiUrl: fields[0] as String,
      activitiesUrl: fields[1] as String,
      termDatesUrl: fields[2] as String,
      announcement: fields[3] as String,
      ads: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, String>())
          .toList(),
      qun: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, String>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, ServerInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.backendApiUrl)
      ..writeByte(1)
      ..write(obj.activitiesUrl)
      ..writeByte(2)
      ..write(obj.termDatesUrl)
      ..writeByte(3)
      ..write(obj.announcement)
      ..writeByte(4)
      ..write(obj.ads)
      ..writeByte(5)
      ..write(obj.qun);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) => ServerInfo(
      backendApiUrl: json['backend_api_url'] as String,
      activitiesUrl: json['activities_url'] as String,
      termDatesUrl: json['term_dates_url'] as String,
      announcement: json['announcement'] as String,
      ads: (json['ads'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      qun: (json['qun'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
    );

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) =>
    <String, dynamic>{
      'backend_api_url': instance.backendApiUrl,
      'activities_url': instance.activitiesUrl,
      'term_dates_url': instance.termDatesUrl,
      'announcement': instance.announcement,
      'ads': instance.ads,
      'qun': instance.qun,
    };
