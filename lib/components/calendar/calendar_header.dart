import 'package:flutter/material.dart';
import 'package:miaomiaoswust/core/values.dart';
import 'package:miaomiaoswust/utils/time.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.displayedMonth,
    required this.onBack,
  });

  final DateTime displayedMonth;
  final Function() onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0), // 平衡视觉
      child: Row(
        children: [
          Text(
            '第${getCourseWeekNum(Values.now)}周',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            '${displayedMonth.year}年${displayedMonth.month.toString().padLeft(2, '0')}月',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.calendar_today,
              ))
        ],
      ),
    );
  }
}
