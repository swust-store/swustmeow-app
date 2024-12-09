import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/core/activity/activity.dart';

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

    return Column(
      children: [
        const Row(
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
        ),
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

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected && isCurrentMonth
                        ? isActivity || isWeekend
                            ? Colors.green.withOpacity(0.4)
                            : context.theme.colorScheme.foreground
                                .withOpacity(0.8)
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          top: 10,
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: !isCurrentMonth
                                  ? Colors.grey
                                  : isWeekend || isActivity
                                      ? Colors.green
                                      : isSelected
                                          ? Colors.white
                                          : context
                                              .theme.colorScheme.foreground,
                            ),
                          )),
                      if (isActivity && activity.name != null)
                        Positioned(
                            top: 32,
                            child: Text(
                              activity.name!,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: !isCurrentMonth
                                      ? Colors.grey
                                      : isWeekend || isActivity
                                          ? Colors.green
                                          : isSelected
                                              ? Colors.white
                                              : context.theme.colorScheme
                                                  .foreground),
                            )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
