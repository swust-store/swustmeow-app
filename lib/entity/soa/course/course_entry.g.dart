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
      isCustom: fields[11] as bool?,
      containerId: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CourseEntry obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.endSection)
      ..writeByte(11)
      ..write(obj.isCustom)
      ..writeByte(12)
      ..write(obj.containerId);
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
      courseName: json['course_name'] as String,
      teacherName: (json['teacher_name'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startWeek: (json['start_week'] as num).toInt(),
      endWeek: (json['end_week'] as num).toInt(),
      place: json['place'] as String,
      weekday: (json['weekday'] as num).toInt(),
      numberOfDay: (json['number_of_day'] as num).toInt(),
      color: (json['color'] as num?)?.toInt() ?? 0xFF000000,
      displayName: json['display_name'] as String,
      startSection: (json['start_section'] as num?)?.toInt(),
      endSection: (json['end_section'] as num?)?.toInt(),
      isCustom: json['is_custom'] as bool?,
      containerId: json['container_id'] as String?,
    );

Map<String, dynamic> _$CourseEntryToJson(CourseEntry instance) =>
    <String, dynamic>{
      'course_name': instance.courseName,
      'teacher_name': instance.teacherName,
      'start_week': instance.startWeek,
      'end_week': instance.endWeek,
      'place': instance.place,
      'weekday': instance.weekday,
      'number_of_day': instance.numberOfDay,
      'color': instance.color,
      'display_name': instance.displayName,
      'start_section': instance.startSection,
      'end_section': instance.endSection,
      'is_custom': instance.isCustom,
      'container_id': instance.containerId,
    };
