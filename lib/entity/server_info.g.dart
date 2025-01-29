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
    );
  }

  @override
  void write(BinaryWriter writer, ServerInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.backendApiUrl)
      ..writeByte(1)
      ..write(obj.activitiesUrl)
      ..writeByte(2)
      ..write(obj.termDatesUrl);
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
      backendApiUrl: json['backendApiUrl'] as String,
      activitiesUrl: json['activitiesUrl'] as String,
      termDatesUrl: json['termDatesUrl'] as String,
    );

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) =>
    <String, dynamic>{
      'backendApiUrl': instance.backendApiUrl,
      'activitiesUrl': instance.activitiesUrl,
      'termDatesUrl': instance.termDatesUrl,
    };
