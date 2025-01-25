// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final int typeId = 5;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.today;
      case 1:
        return ActivityType.shift;
      case 2:
        return ActivityType.common;
      case 3:
        return ActivityType.festival;
      case 4:
        return ActivityType.bigHoliday;
      case 5:
        return ActivityType.hidden;
      default:
        return ActivityType.today;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.today:
        writer.writeByte(0);
        break;
      case ActivityType.shift:
        writer.writeByte(1);
        break;
      case ActivityType.common:
        writer.writeByte(2);
        break;
      case ActivityType.festival:
        writer.writeByte(3);
        break;
      case ActivityType.bigHoliday:
        writer.writeByte(4);
        break;
      case ActivityType.hidden:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
