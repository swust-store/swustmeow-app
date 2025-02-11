// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamScheduleAdapter extends TypeAdapter<ExamSchedule> {
  @override
  final int typeId = 18;

  @override
  ExamSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamSchedule(
      type: fields[0] as ExamType,
      courseName: fields[1] as String,
      weekNum: fields[2] as int,
      numberOfDay: fields[3] as int,
      weekday: fields[4] as int,
      date: fields[5] as DateTime,
      place: fields[6] as String,
      classroom: fields[7] as String,
      seatNo: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ExamSchedule obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.weekNum)
      ..writeByte(3)
      ..write(obj.numberOfDay)
      ..writeByte(4)
      ..write(obj.weekday)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.place)
      ..writeByte(7)
      ..write(obj.classroom)
      ..writeByte(8)
      ..write(obj.seatNo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamSchedule _$ExamScheduleFromJson(Map<String, dynamic> json) => ExamSchedule(
      type: $enumDecode(_$ExamTypeEnumMap, json['type']),
      courseName: json['courseName'] as String,
      weekNum: (json['weekNum'] as num).toInt(),
      numberOfDay: (json['numberOfDay'] as num).toInt(),
      weekday: (json['weekday'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      place: json['place'] as String,
      classroom: json['classroom'] as String,
      seatNo: (json['seatNo'] as num).toInt(),
    );

Map<String, dynamic> _$ExamScheduleToJson(ExamSchedule instance) =>
    <String, dynamic>{
      'type': _$ExamTypeEnumMap[instance.type]!,
      'courseName': instance.courseName,
      'weekNum': instance.weekNum,
      'numberOfDay': instance.numberOfDay,
      'weekday': instance.weekday,
      'date': instance.date.toIso8601String(),
      'place': instance.place,
      'classroom': instance.classroom,
      'seatNo': instance.seatNo,
    };

const _$ExamTypeEnumMap = {
  ExamType.finalExam: 'finalExam',
  ExamType.midExam: 'midExam',
  ExamType.resitExam: 'resitExam',
};
