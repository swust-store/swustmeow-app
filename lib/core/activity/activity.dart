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

  bool isInActivity(DateTime date) {
    final tryGet = dateStringGetter == null ? null : dateStringGetter!(date);
    final ds = tryGet ?? dateString;
    if (ds == null) return false;
    final parsedDateStart = dateStringToDate(ds.split('-').first);
    final parsedDateEnd = dateStringToDate(ds.split('-').last);

    // final before = DateTime(date.year - 1, date.month, date.day);
    // final after = DateTime(date.year + 1, date.month, date.day);

    if (ds.split('-').length == 3) {
      return isYMDInRange(date, parsedDateStart, parsedDateEnd);
    }

    if (parsedDateStart.monthDayEquals(parsedDateEnd)) {
      return date.monthDayEquals(parsedDateStart);
    } else {
      // return isMDInRange(before, parsedDateStart, parsedDateEnd) ||
      //     isMDInRange(date, parsedDateStart, parsedDateEnd) ||
      //     isMDInRange(after, parsedDateStart, parsedDateEnd);
      return isMDInRange(date, parsedDateStart, parsedDateEnd);
    }
  }
}
