// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

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
