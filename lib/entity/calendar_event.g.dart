// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      eventId: json['eventId'] as String,
      calendarId: json['calendarId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      start: json['start'] == null
          ? null
          : DateTime.parse(json['start'] as String),
      end: json['end'] == null ? null : DateTime.parse(json['end'] as String),
      allDay: json['allDay'] as bool? ?? false,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'calendarId': instance.calendarId,
      'title': instance.title,
      'description': instance.description,
      'start': instance.start?.toIso8601String(),
      'end': instance.end?.toIso8601String(),
      'allDay': instance.allDay,
      'location': instance.location,
    };
