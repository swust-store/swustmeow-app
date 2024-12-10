import 'package:miaomiaoswust/utils/time.dart';

import 'activity_type.dart';

class Activity {
  const Activity(
      {this.name,
      required this.type,
      this.holiday = true,
      this.display = true,
      this.dateString,
      this.dateStringGetter,
      this.greetings,
      this.greetingsGetter});

  final String? name;
  final ActivityType type;
  final bool holiday; // 是否放假
  final bool display; // 是否展示在日历中，通常为前夕此类设为 `false`
  final String? dateString;
  final String Function(DateTime date)? dateStringGetter; // 获取日期字符串的函数
  final List<String>? greetings;
  final List<String> Function(DateTime date)? greetingsGetter; // 获取问候语的函数

  factory Activity.common(
          {required String name,
          bool holiday = false,
          bool display = true,
          String? dateString,
          String Function(DateTime date)? dateStringGetter,
          List<String>? greetings,
          List<String> Function(DateTime date)? greetingsGetter}) =>
      Activity(
          name: name,
          type: ActivityType.common,
          holiday: holiday,
          display: display,
          dateString: dateString,
          dateStringGetter: dateStringGetter,
          greetings: greetings,
          greetingsGetter: greetingsGetter);

  factory Activity.festival(
          {String? name,
          bool holiday = true,
          bool display = true,
          String? dateString,
          String Function(DateTime date)? dateStringGetter,
          List<String>? greetings,
          List<String> Function(DateTime date)? greetingsGetter}) =>
      Activity(
          name: name,
          type: ActivityType.festival,
          holiday: holiday,
          display: display,
          dateString: dateString,
          dateStringGetter: dateStringGetter,
          greetings: greetings,
          greetingsGetter: greetingsGetter);

  factory Activity.shift({
    String? dateString,
    String Function(DateTime date)? dateStringGetter,
  }) =>
      Activity(
        type: ActivityType.shift,
        holiday: false,
        dateString: dateString,
        dateStringGetter: dateStringGetter,
      );

  factory Activity.hidden({
    bool holiday = false,
    String? dateString,
    String Function(DateTime date)? dateStringGetter,
    List<String>? greetings,
    List<String> Function(DateTime date)? greetingsGetter,
  }) =>
      Activity(
          type: ActivityType.hidden,
          holiday: holiday,
          display: false,
          greetings: greetings,
          greetingsGetter: greetingsGetter);

  String? getDateString(DateTime date) {
    final tryGet = dateStringGetter == null ? null : dateStringGetter!(date);
    return tryGet ?? dateString;
  }

  DateTime getParsedDateStart(String dateString) =>
      dateStringToDate(dateString.split('-').first);

  DateTime getParsedDateEnd(String dateString) =>
      dateStringToDate(dateString.split('-').last);

  bool isInActivity(DateTime date) {
    final ds = getDateString(date);
    if (ds == null) return false;
    final parsedDateStart = getParsedDateStart(ds);
    final parsedDateEnd = getParsedDateEnd(ds);

    if (ds.split('-').length == 3) {
      return isYMDInRange(date, parsedDateStart, parsedDateEnd);
    }

    if (parsedDateStart.monthDayEquals(parsedDateEnd)) {
      return date.monthDayEquals(parsedDateStart);
    } else {
      return isMDInRange(date, parsedDateStart, parsedDateEnd);
    }
  }
}
