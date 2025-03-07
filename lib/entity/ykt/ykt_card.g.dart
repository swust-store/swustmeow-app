// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ykt_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YKTCardAdapter extends TypeAdapter<YKTCard> {
  @override
  final int typeId = 29;

  @override
  YKTCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YKTCard(
      account: fields[0] as String,
      cardName: fields[1] as String,
      departmentName: fields[2] as String,
      expireDate: fields[3] as String,
      name: fields[4] as String,
      accountInfos: (fields[5] as List).cast<YKTCardAccountInfo>(),
    );
  }

  @override
  void write(BinaryWriter writer, YKTCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.account)
      ..writeByte(1)
      ..write(obj.cardName)
      ..writeByte(2)
      ..write(obj.departmentName)
      ..writeByte(3)
      ..write(obj.expireDate)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.accountInfos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YKTCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
