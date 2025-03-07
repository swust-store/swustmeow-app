// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apartment_auth_token.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApartmentAuthTokenAdapter extends TypeAdapter<ApartmentAuthToken> {
  @override
  final int typeId = 21;

  @override
  ApartmentAuthToken read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApartmentAuthToken(
      tokenType: fields[0] as String,
      token: fields[1] as String,
      expireDate: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ApartmentAuthToken obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.tokenType)
      ..writeByte(1)
      ..write(obj.token)
      ..writeByte(2)
      ..write(obj.expireDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApartmentAuthTokenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
