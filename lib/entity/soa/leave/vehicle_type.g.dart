// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleTypeAdapter extends TypeAdapter<VehicleType> {
  @override
  final int typeId = 16;

  @override
  VehicleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VehicleType.car;
      case 1:
        return VehicleType.train;
      case 2:
        return VehicleType.plane;
      case 3:
        return VehicleType.bike;
      case 4:
        return VehicleType.other;
      default:
        return VehicleType.car;
    }
  }

  @override
  void write(BinaryWriter writer, VehicleType obj) {
    switch (obj) {
      case VehicleType.car:
        writer.writeByte(0);
        break;
      case VehicleType.train:
        writer.writeByte(1);
        break;
      case VehicleType.plane:
        writer.writeByte(2);
        break;
      case VehicleType.bike:
        writer.writeByte(3);
        break;
      case VehicleType.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
