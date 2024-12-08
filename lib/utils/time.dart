import 'package:lunar/calendar/Solar.dart';

import '../core/values.dart';

bool isInRange(DateTime date, DateTime start, DateTime end) =>
    (date.monthDayEquals(start) || date.isAfter(start)) &&
    (date.monthDayEquals(end) || date.isBefore(end));

bool isHourMinuteInRange(
    String? time, String left, String right, String splitPattern) {
  time = time ??
      '${Values.now.hour.toString().padLeft(2, '0')}:${Values.now.minute.toString().padLeft(2, '0')}';
  split(String string) => string.split(splitPattern).map(int.parse).toList();
  final format = DateTime(0);
  final timeSplit = split(time);
  final leftSplit = split(left);
  final rightSplit = split(right);

  final givenTime = DateTime(
      format.year, format.month, format.day, timeSplit[0], timeSplit[1]);
  final startTime = DateTime(
      format.year, format.month, format.day, leftSplit[0], leftSplit[1]);
  final endTime = DateTime(
      format.year, format.month, format.day, rightSplit[0], rightSplit[1]);

  return isInRange(givenTime, startTime, endTime);
}

int getWeekNumber() {
  final year = DateTime.now().year;
  var sep = DateTime(year, 9);
  while (true) {
    if (sep.weekday != 1) {
      sep = sep.add(const Duration(days: 1));
    } else {
      break;
    }
  }
  final diff = DateTime.now().difference(sep);
  return ((diff.inDays + 1) / 7).ceil();
}

DateTime dateStringToDate(String dateString, [final String pattern = '.']) {
  dateString = dateString.replaceAll(pattern, '.');
  final checked =
      dateString.split('.').map((it) => it.padLeft(2, '0')).toList();
  return DateTime.parse(checked.length == 3
      ? checked.join('-')
      : '${Values.now.year}-${checked.join('-')}');
}

List<DateTime> findDateTimes(
    DateTime start, DateTime end, bool Function(DateTime it) test) {
  var current = start;
  final result = <DateTime>[];
  while (true) {
    if (test(current)) result.add(current);
    if (current.year == end.year &&
        current.month == end.month &&
        current.day == end.day) break;
  }
  return result;
}

extension DateTimeExtension on DateTime {
  DateTime get yesterday => subtract(const Duration(days: 1));

  String get dateString =>
      '${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}';

  bool monthDayEquals(DateTime other) =>
      other.month == month && other.day == day;
}

extension SolarExtension on Solar {
  String get dateString =>
      '${getMonth().toString().padLeft(2, '0')}.${getDay().toString().padLeft(2, '0')}';
}
