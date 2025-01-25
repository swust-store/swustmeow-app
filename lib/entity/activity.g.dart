// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 3;

  @override
  Activity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activity(
      name: fields[0] as String?,
      type: fields[1] as ActivityType,
      holiday: fields[2] as bool,
      display: fields[3] as bool,
      dateString: fields[4] as String?,
      greetings: (fields[5] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.holiday)
      ..writeByte(3)
      ..write(obj.display)
      ..writeByte(4)
      ..write(obj.dateString)
      ..writeByte(5)
      ..write(obj.greetings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      name: json['name'] as String?,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      holiday: json['holiday'] as bool? ?? true,
      display: json['display'] as bool? ?? true,
      dateString: json['dateString'] as String?,
      greetings: (json['greetings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'name': instance.name,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'holiday': instance.holiday,
      'display': instance.display,
      'dateString': instance.dateString,
      'greetings': instance.greetings,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.today: 'today',
  ActivityType.shift: 'shift',
  ActivityType.common: 'common',
  ActivityType.festival: 'festival',
  ActivityType.bigHoliday: 'bigHoliday',
  ActivityType.hidden: 'hidden',
};
