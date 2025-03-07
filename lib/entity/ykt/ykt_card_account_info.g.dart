// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ykt_card_account_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YKTCardAccountInfoAdapter extends TypeAdapter<YKTCardAccountInfo> {
  @override
  final int typeId = 31;

  @override
  YKTCardAccountInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YKTCardAccountInfo(
      name: fields[0] as String,
      type: fields[1] as String,
      balance: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, YKTCardAccountInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YKTCardAccountInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
