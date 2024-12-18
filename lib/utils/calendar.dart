import 'package:device_calendar/device_calendar.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/entity/calendar_event.dart';
import 'package:miaomiaoswust/entity/system_calendar.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

Future<StatusContainer<dynamic>> _checkPermission() async {
  final permissionGranted = await _deviceCalendarPlugin.hasPermissions();
  if (!permissionGranted.isSuccess || !permissionGranted.data!) {
    final result = await _deviceCalendarPlugin.requestPermissions();
    if (!result.isSuccess || !result.data!) {
      return const StatusContainer(Status.notAuthorized);
    }
  }
  return const StatusContainer(Status.ok);
}

Future<StatusContainer<List<SystemCalendar>>> fetchAllSystemCalendars() async {
  final p = await _checkPermission();
  if (p.status != Status.ok) return p as StatusContainer<List<SystemCalendar>>;

  final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
  if (!calendarResult.isSuccess) {
    return const StatusContainer(Status.fail);
  }

  final List<SystemCalendar> result = [];
  for (final calendar in calendarResult.data!) {
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
            startDate: Values.now.subtract(const Duration(days: 365)),
            endDate: Values.now.add(const Duration(days: 365))));

    if (eventsResult.isSuccess && eventsResult.data != null) {
      result.add(SystemCalendar(
          name: calendar.name!, id: calendar.id!, events: eventsResult.data!));
    }
  }

  return StatusContainer(Status.ok, result);
}

Future<StatusContainer<dynamic>> addEvent(String title, String? description,
    String? location, DateTime start, DateTime end, bool allDay) async {
  final p = await _checkPermission();
  if (p.status != Status.ok) return p as StatusContainer<String>;

  final prefs = await SharedPreferences.getInstance();
  var calendarId = prefs.getString('calendarId');

  // 如果不存在日历则创建
  if (calendarId == null) {
    final createResult = await _deviceCalendarPlugin.createCalendar('喵喵西科',
        localAccountName: 'miaomiaoswust');
    if (createResult.isSuccess) {
      calendarId = createResult.data!;
      await prefs.setString('calendarId', calendarId);
    } else {
      return const StatusContainer(Status.fail, '创建日历失败');
    }
  }

  final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  if (!calendarsResult.isSuccess) {
    return const StatusContainer(Status.fail, '获取日历失败');
  }

  final event = Event(calendarId,
      title: title,
      description: description,
      location: location,
      start: tz.TZDateTime.from(start, tz.local),
      end: tz.TZDateTime.from(end, tz.local),
      allDay: allDay);
  final addResult = await _deviceCalendarPlugin.createOrUpdateEvent(event);

  if (addResult == null || addResult.isSuccess != true) {
    return const StatusContainer(Status.fail, '创建事件失败');
  }

  return StatusContainer(
      Status.ok,
      CalendarEvent(
          eventId: addResult.data!,
          calendarId: calendarId,
          title: title,
          start: start,
          end: end));
}

Future<StatusContainer<String>> removeEvent(String eventId) async {
  final scsResult = await fetchAllSystemCalendars();
  if (scsResult.status != Status.ok) {
    return const StatusContainer(Status.fail, '获取日历失败（1）');
  }

  String? calendarId;
  for (final sc in scsResult.value!) {
    for (final event in sc.events) {
      if (event.eventId == eventId) {
        calendarId = sc.id;
        break;
      }
    }
  }

  if (calendarId == null) {
    return const StatusContainer(Status.fail, '获取日历失败（2）');
  }

  final result = await _deviceCalendarPlugin.deleteEvent(calendarId, eventId);
  if (result.isSuccess) return const StatusContainer(Status.ok);

  return const StatusContainer(Status.fail, '无法删除事件');
}
