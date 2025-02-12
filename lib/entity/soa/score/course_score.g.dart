// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseScoreAdapter extends TypeAdapter<CourseScore> {
  @override
  final int typeId = 20;

  @override
  CourseScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseScore(
      courseName: fields[0] as String,
      courseId: fields[1] as String,
      credit: fields[2] as double,
      courseType: fields[3] as String?,
      formalScore: fields[4] as String,
      resitScore: fields[5] as String,
      points: fields[6] as double?,
      scoreType: fields[7] as ScoreType,
      term: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CourseScore obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.courseName)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.credit)
      ..writeByte(3)
      ..write(obj.courseType)
      ..writeByte(4)
      ..write(obj.formalScore)
      ..writeByte(5)
      ..write(obj.resitScore)
      ..writeByte(6)
      ..write(obj.points)
      ..writeByte(7)
      ..write(obj.scoreType)
      ..writeByte(8)
      ..write(obj.term);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseScore _$CourseScoreFromJson(Map<String, dynamic> json) => CourseScore(
      courseName: json['courseName'] as String,
      courseId: json['courseId'] as String,
      credit: (json['credit'] as num).toDouble(),
      courseType: json['courseType'] as String?,
      formalScore: json['formalScore'] as String,
      resitScore: json['resitScore'] as String,
      points: (json['points'] as num?)?.toDouble(),
      scoreType: $enumDecode(_$ScoreTypeEnumMap, json['scoreType']),
      term: json['term'] as String,
    );

Map<String, dynamic> _$CourseScoreToJson(CourseScore instance) =>
    <String, dynamic>{
      'courseName': instance.courseName,
      'courseId': instance.courseId,
      'credit': instance.credit,
      'courseType': instance.courseType,
      'formalScore': instance.formalScore,
      'resitScore': instance.resitScore,
      'points': instance.points,
      'scoreType': _$ScoreTypeEnumMap[instance.scoreType]!,
      'term': instance.term,
    };

const _$ScoreTypeEnumMap = {
  ScoreType.plan: 'plan',
  ScoreType.common: 'common',
  ScoreType.physical: 'physical',
};
