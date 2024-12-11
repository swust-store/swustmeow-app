import '../../utils/time.dart';
import 'activity_date_type.dart';
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

  factory Activity.bigHoliday(
          {String? name,
          bool holiday = true,
          bool display = true,
          String? dateString,
          String Function(DateTime date)? dateStringGetter,
          List<String>? greetings,
          List<String> Function(DateTime date)? greetingsGetter}) =>
      Activity(
          name: name,
          type: ActivityType.bigHoliday,
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

  (ActivityDateType, (DateTime?, DateTime?)) getDateRange(DateTime date) {
    final ds = getDateString(date);
    if (ds == null) return (ActivityDateType.none, (null, null));
    final split = ds.split('-');
    final startDateString = split.first;
    final endDateString = split.last;

    // 范围
    if (split.length == 2) {
      final startSplit = startDateString.split('.');
      final endSplit = endDateString.split('.');
      final sl = startSplit.length;
      final el = endSplit.length;

      // 特殊情况，如 2024.10.17-10.25
      // 解析为 2024.10.14 - 2024.10.25
      final fYear = sl == 3 ? startSplit.first : endSplit.first;
      if (sl == 3 && el == 2) {
        endSplit.insert(0, fYear);
      } else if (sl == 2 && el == 3) {
        startSplit.insert(0, fYear);
      }

      final parsedStart = dateStringToDate(startSplit.join('.'));
      final parsedEnd = dateStringToDate(endSplit.join('.'));

      return (
        sl == 2 && el == 2
            ? ActivityDateType.dynamicMDRange
            : ActivityDateType.staticYMDRange,
        (parsedStart, parsedEnd)
      );
    }

    // 单个日期
    if (split.length == 1 || startDateString == endDateString) {
      final res = dateStringToDate(startDateString);
      return (ActivityDateType.single, (res, res));
    }

    return (ActivityDateType.none, (null, null));
  }

  bool get isFestival =>
      type == ActivityType.festival || type == ActivityType.bigHoliday;

  bool get isShift => type == ActivityType.shift;

  bool isInActivity(DateTime date) {
    final ds = getDateString(date);
    if (ds == null) return false;

    final (type, (start, end)) = getDateRange(date);
    switch (type) {
      case ActivityDateType.none:
        return false;
      case ActivityDateType.single:
        return date.monthDayEquals(start!);
      case ActivityDateType.dynamicMDRange:
        return isMDInRange(date, start!, end!, dynamicYear: true);
      case ActivityDateType.staticYMDRange:
        return isYMDInRange(date, start!, end!);
    }
  }
}
