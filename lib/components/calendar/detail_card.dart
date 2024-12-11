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

  String? _getWeekInfo() {
    final d = getCourseWeekNum(selectedDate);
    if (d <= 0) return null;
    const w = ['一', '二', '三', '四', '五', '六', '日'];
    return '教学第${d.padL2}周 周${w[selectedDate.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final activityMatched = activities
        .where((activity) => activity.isInActivity(selectedDate))
        .toList();
    activityMatched
        .sort((a, b) => b.type.priority.compareTo(a.type.priority)); // 降序排序
    final activity = activityMatched.firstOrNull;
    final isActivity = activity != null && activityMatched.isNotEmpty;
    final displayActivities = activityMatched.where((ac) => ac.name != null);
    final weekInfo = _getWeekInfo();
    final fg = context.theme.colorScheme.foreground;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedDate.year}年${selectedDate.month.padL2}月${selectedDate.day.padL2}日',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (weekInfo != null) Text(weekInfo),
            const SizedBox(
              height: 6,
            ),
            if (isActivity && displayActivities.isNotEmpty)
              ...displayActivities.map(
                (ac) => Text('⬤ ${ac.name}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            ac.isFestival && !ac.holiday ? fg : ac.type.color)),
              ),
          ],
        ),
      ),
    );
  }
}
