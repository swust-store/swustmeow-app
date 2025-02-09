// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveTypeAdapter extends TypeAdapter<LeaveType> {
  @override
  final int typeId = 17;

  @override
  LeaveType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LeaveType.seekJob;
      case 1:
        return LeaveType.intern;
      case 2:
        return LeaveType.returnHome;
      case 3:
        return LeaveType.train;
      case 4:
        return LeaveType.trip;
      case 5:
        return LeaveType.sickLeave;
      case 6:
        return LeaveType.personalLeave;
      default:
        return LeaveType.seekJob;
    }
  }

  @override
  void write(BinaryWriter writer, LeaveType obj) {
    switch (obj) {
      case LeaveType.seekJob:
        writer.writeByte(0);
        break;
      case LeaveType.intern:
        writer.writeByte(1);
        break;
      case LeaveType.returnHome:
        writer.writeByte(2);
        break;
      case LeaveType.train:
        writer.writeByte(3);
        break;
      case LeaveType.trip:
        writer.writeByte(4);
        break;
      case LeaveType.sickLeave:
        writer.writeByte(5);
        break;
      case LeaveType.personalLeave:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
