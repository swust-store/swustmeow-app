import 'package:json_annotation/json_annotation.dart';
import 'package:miaomiaoswust/utils/time.dart';

part 'calendar_event.g.dart';

@JsonSerializable()
class CalendarEvent {
  const CalendarEvent(
      {required this.eventId,
      required this.calendarId,
      required this.title,
      this.description,
      required this.start,
      required this.end,
      this.allDay = false,
      this.location});

  final String eventId;
  final String calendarId;
  final String title;
  final String? description;
  final DateTime? start;
  final DateTime? end;
  final bool allDay;
  final String? location;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  bool isInEvent(DateTime date) {
    if (start != null && end != null) return isYMDInRange(date, start!, end!);

    if (start != null && end == null) {
      return date.yearMonthDayEquals(start!) || date.isAfter(start!);
    }

    if (start == null && end != null) {
      return date.yearMonthDayEquals(end!) || date.isBefore(end!);
    }

    return false;
  }
}
