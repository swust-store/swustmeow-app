// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseEntryAdapter extends TypeAdapter<CourseEntry> {
  @override
  final int typeId = 1;

  @override
  CourseEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseEntry(
      courseName: fields[0] as String,
      teacherName: (fields[1] as List).cast<String>(),
      startWeek: fields[2] as int,
      endWeek: fields[3] as int,
      place: fields[4] as String,
      weekday: fields[5] as int,
      numberOfDay: fields[6] as int,
      color: fields[7] as int,
      displayName: fields[8] as String,
      startSection: fields[9] as int?,
      endSection: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CourseEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.courseName)
      ..writeByte(1)
      ..write(obj.teacherName)
      ..writeByte(2)
      ..write(obj.startWeek)
      ..writeByte(3)
      ..write(obj.endWeek)
      ..writeByte(4)
      ..write(obj.place)
      ..writeByte(5)
      ..write(obj.weekday)
      ..writeByte(6)
      ..write(obj.numberOfDay)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.displayName)
      ..writeByte(9)
      ..write(obj.startSection)
      ..writeByte(10)
      ..write(obj.endSection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseEntry _$CourseEntryFromJson(Map<String, dynamic> json) => CourseEntry(
      courseName: json['courseName'] as String,
      teacherName: (json['teacherName'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startWeek: (json['startWeek'] as num).toInt(),
      endWeek: (json['endWeek'] as num).toInt(),
      place: json['place'] as String,
      weekday: (json['weekday'] as num).toInt(),
      numberOfDay: (json['numberOfDay'] as num).toInt(),
      color: (json['color'] as num?)?.toInt() ?? 0xFF000000,
      displayName: json['displayName'] as String,
      startSection: (json['startSection'] as num?)?.toInt(),
      endSection: (json['endSection'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CourseEntryToJson(CourseEntry instance) =>
    <String, dynamic>{
      'courseName': instance.courseName,
      'teacherName': instance.teacherName,
      'startWeek': instance.startWeek,
      'endWeek': instance.endWeek,
      'place': instance.place,
      'weekday': instance.weekday,
      'numberOfDay': instance.numberOfDay,
      'color': instance.color,
      'displayName': instance.displayName,
      'startSection': instance.startSection,
      'endSection': instance.endSection,
    };
