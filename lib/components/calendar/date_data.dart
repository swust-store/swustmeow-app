import 'package:miaomiaoswust/core/activity/activity.dart';

class DateData {
  const DateData(
      {required this.date,
      required this.isCurrentMonth,
      required this.isWeekend,
      required this.isSelected,
      required this.isActivity,
      required this.isHoliday,
      required this.activity});

  final DateTime date;
  final bool isCurrentMonth;
  final bool isWeekend;
  final bool isSelected;
  final bool isActivity;
  final bool isHoliday;
  final Activity? activity;
}
