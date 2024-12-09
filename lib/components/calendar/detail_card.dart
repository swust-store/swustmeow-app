import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/core/activity/activity.dart';
import 'package:miaomiaoswust/utils/time.dart';

class DetailCard extends StatelessWidget {
  const DetailCard({
    super.key,
    required this.selectedDate,
    required this.activities,
  });

  final DateTime selectedDate;
  final List<Activity> activities;

  String _getWeekInfo() {
    const w = ['一', '二', '三', '四', '五', '六', '日'];
    return '教学第${getCourseWeekNum(selectedDate).toString().padLeft(2, '0')}周 周${w[selectedDate.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final activity = activities
        .where((activity) => activity.isInActivity(selectedDate))
        .firstOrNull;
    final isActivity = activity != null;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedDate.month.toString().padLeft(2, '0')}月${selectedDate.day.toString().padLeft(2, '0')}日',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_getWeekInfo()),
            if (isActivity) ...[
              const SizedBox(height: 16),
              Text(
                '${activity.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
