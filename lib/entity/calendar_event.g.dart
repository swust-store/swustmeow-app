// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarEventAdapter extends TypeAdapter<CalendarEvent> {
  @override
  final int typeId = 0;

  @override
  CalendarEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarEvent(
      eventId: fields[0] as String,
      calendarId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String?,
      start: fields[4] as DateTime?,
      end: fields[5] as DateTime?,
      allDay: fields[6] as bool,
      location: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CalendarEvent obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.calendarId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.start)
      ..writeByte(5)
      ..write(obj.end)
      ..writeByte(6)
      ..write(obj.allDay)
      ..writeByte(7)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
