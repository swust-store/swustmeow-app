import 'package:miaomiaoswust/core/values.dart';
import 'package:miaomiaoswust/utils/time.dart';

import 'activity_type.dart';

class Activity {
  const Activity(
      {this.name,
      required this.type,
      this.holiday = true,
      this.display = true,
      required this.dateString,
      this.greetings});

  final String? name;
  final ActivityType type;
  final bool holiday; // 是否放假
  final bool display; // 是否展示在日历中，通常为前夕此类设为 `false`
  final String dateString;
  final List<String>? greetings;

  factory Activity.common(
          {required String name,
          bool holiday = false,
          bool display = true,
          required String dateString,
          List<String>? greetings}) =>
      Activity(
          name: name,
          type: ActivityType.common,
          holiday: holiday,
          display: display,
          dateString: dateString,
          greetings: greetings);

  factory Activity.festival(
          {String? name,
          bool holiday = true,
          bool display = true,
          required String dateString,
          List<String>? greetings}) =>
      Activity(
          name: name,
          type: ActivityType.festival,
          holiday: holiday,
          display: display,
          dateString: dateString,
          greetings: greetings);

  factory Activity.shift({required String dateString}) => Activity(
        type: ActivityType.shift,
        holiday: false,
        dateString: dateString,
      );

  DateTime get parsedDateStart => dateStringToDate(dateString.split('-').first);

  DateTime get parsedDateEnd => dateStringToDate(dateString.split('-').last);

  bool isInActivity([DateTime? date]) {
    date = date ?? Values.now;
    final before = DateTime(date.year - 1, date.month, date.day);
    final after = DateTime(date.year + 1, date.month, date.day);

    if (dateString.split('-').length == 3) {
      return isYMDInRange(date, parsedDateStart, parsedDateEnd);
    }

    if (parsedDateStart.monthDayEquals(parsedDateEnd)) {
      return date.monthDayEquals(parsedDateStart);
    } else {
      return isMDInRange(before, parsedDateStart, parsedDateEnd) ||
          isMDInRange(date, parsedDateStart, parsedDateEnd) ||
          isMDInRange(after, parsedDateStart, parsedDateEnd);
    }
  }
}
