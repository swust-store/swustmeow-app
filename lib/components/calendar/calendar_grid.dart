import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/calendar/date_data.dart';
import 'package:miaomiaoswust/components/empty.dart';
import 'package:miaomiaoswust/core/activity/activity.dart';
import 'package:miaomiaoswust/core/activity/activity_type.dart';

import '../../utils/text.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.activities,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final List<Activity> activities;
  final Function(DateTime) onDateSelected;

  List<DateTime> _getDaysInMonth() {
    final DateTime firstDay =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final int firstWeekday = firstDay.weekday;
    final List<DateTime> days = [];

    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    for (int i = 0; i < 31; i++) {
      final DateTime day = firstDay.add(Duration(days: i));
      if (day.month == displayedMonth.month) {
        days.add(day);
      }
    }

    while (days.length < 42) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final bg = context.theme.colorScheme.background;
    final fg = context.theme.colorScheme.foreground;

    return Column(
      children: [
        _buildWeekdaysRow(),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth = date.month == displayedMonth.month;
              final isWeekend = date.weekday >= 6;
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final activity = activities
                  .where((activity) => activity.isInActivity(date))
                  .firstOrNull;
              final isActivity = activity != null;
              final isHoliday = (!isActivity && isWeekend) ||
                  (isActivity && activity.holiday) ||
                  (isWeekend &&
                      isActivity &&
                      !activity.holiday &&
                      activity.type != ActivityType.shift);
              final dateData = DateData(
                  date: date,
                  isCurrentMonth: isCurrentMonth,
                  isWeekend: isWeekend,
                  isSelected: isSelected,
                  isActivity: isActivity,
                  isHoliday: isHoliday,
                  activity: activity);

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  color: isSelected
                      ? (isActivity &&
                              !(activity.type == ActivityType.festival &&
                                  !activity.holiday))
                          ? activity.type.color
                              .withOpacity(isCurrentMonth ? 0.1 : 0.05)
                          : null
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSelected ? 100 : 0),
                    child: Container(
                      color: _calculateDateBackgroundColor(bg, fg, dateData),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                    color:
                                        _calculateDateColor(bg, fg, dateData)),
                              )),
                          ..._getBadges(bg, fg, dateData)
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaysRow() => const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('一'),
          Text('二'),
          Text('三'),
          Text('四'),
          Text('五'),
          Text('六', style: TextStyle(color: Colors.green)),
          Text('日', style: TextStyle(color: Colors.green)),
        ],
      );

  List<Widget> _getBadges(Color bg, Color fg, DateData data) {
    if (!data.isActivity || data.activity == null) return [const Empty()];
    final color = data.isSelected && data.isCurrentMonth
        ? Colors.white
        : _calculateDateColor(bg, fg, data);

    switch (data.activity!.type) {
      case ActivityType.festival:
        return data.activity!.name == null
            ? [const Empty()]
            : [
                Positioned(
                    top: 34,
                    child: Text(
                      data.activity!.name!,
                      style: TextStyle(fontSize: 8, color: color),
                    )),
                if (data.activity?.holiday == true)
                  Positioned(
                      top: 10,
                      right: 10,
                      child: Text(
                        '休',
                        style: TextStyle(fontSize: 6, color: color),
                      ))
              ];
      case ActivityType.common:
        return [
          Positioned(
              top: 34,
              child: Text(
                overflowed(data.activity!.name ?? '事件', 5),
                style: TextStyle(fontSize: 8, color: color),
              ))
        ];
      case ActivityType.shift:
        return [
          Positioned(
              top: 10,
              right: 10,
              child: Text(
                '班',
                style: TextStyle(fontSize: 6, color: color),
              ))
        ];
    }
  }

  Color _calculateDateBackgroundUnselectedColor(Color bg, DateData data) {
    final op = data.isCurrentMonth ? 0.1 : 0.05;
    if (!data.isActivity ||
        (data.isActivity &&
            data.activity?.type == ActivityType.festival &&
            data.activity?.holiday == false)) return bg;
    return data.activity?.type.color.withOpacity(op) ?? bg;
  }

  Color? _calculateDateBackgroundColor(Color bg, Color fg, DateData data) {
    if (!data.isSelected) {
      return _calculateDateBackgroundUnselectedColor(bg, data);
    }

    final result = data.isHoliday
        ? ActivityType.festival.color
        : data.activity?.type == ActivityType.festival
            ? fg
            : data.activity?.type.color ?? fg;
    return result.withOpacity(data.isCurrentMonth ? 0.8 : 0.1);
  }

  Color? _calculateDateColor(Color bg, Color fg, DateData data) {
    if (data.isSelected && data.isCurrentMonth) return bg;

    const op = 0.4;
    if (data.activity == null && !data.isHoliday) {
      return fg.withOpacity(data.isCurrentMonth ? 1 : op);
    }

    final result = data.isHoliday
        ? ActivityType.festival.color
        : data.activity?.type == ActivityType.festival
            ? fg
            : data.activity?.type.color ?? fg;
    return data.isCurrentMonth ? result : result.withOpacity(op);
  }
}
