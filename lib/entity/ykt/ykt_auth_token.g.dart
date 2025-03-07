// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ykt_auth_token.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YKTAuthTokenAdapter extends TypeAdapter<YKTAuthToken> {
  @override
  final int typeId = 30;

  @override
  YKTAuthToken read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YKTAuthToken(
      accessToken: fields[0] as String,
      refreshToken: fields[1] as String,
      expiresIn: fields[2] as int,
      tokenType: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, YKTAuthToken obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.expiresIn)
      ..writeByte(3)
      ..write(obj.tokenType)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YKTAuthTokenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
