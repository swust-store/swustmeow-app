import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../entity/activity.dart';
import '../../entity/activity_type.dart';
import '../../entity/date_data.dart';
import '../../utils/text.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.activities,
    required this.onDateSelected,
    required this.showBadges,
    required this.getIsInEvent,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final List<Activity> activities;
  final Function(DateTime) onDateSelected;
  final bool showBadges;
  final bool Function(DateTime) getIsInEvent;
  static const fallbackColor = Colors.purple;

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
        _buildWeekdaysRow(),
        const SizedBox(
          height: 8,
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
            itemBuilder: (context, index) => _buildItem(context, index, days),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index, List<DateTime> days) {
    final bg = context.theme.colorScheme.background;
    final fg = context.theme.colorScheme.foreground;
    final date = days[index];
    final isCurrentMonth = date.month == displayedMonth.month;
    final isWeekend = date.weekday >= 6;
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
    final activityMatched =
        activities.where((activity) => activity.isInActivity(date)).toList();
    activityMatched.sort((a, b) => ActivityTypeData.of(b.type)
        .priority
        .compareTo(ActivityTypeData.of(a.type).priority)); // 降序排序
    final activity = activityMatched.firstOrNull;
    final isActivity = activity != null && activityMatched.isNotEmpty;
    final isHoliday = (!isActivity && isWeekend) ||
        (isActivity && activity.holiday) ||
        (isWeekend && isActivity && !activity.holiday && activity.isShift);
    final noDisplay = activityMatched.where((ac) => ac.display).isEmpty ||
        activity?.type == ActivityType.hidden;
    final isInEvent = getIsInEvent(date);
    final dateData = DateData(
      date: date,
      isCurrentMonth: isCurrentMonth,
      isWeekend: isWeekend,
      isSelected: isSelected,
      isActivity: isActivity,
      isHoliday: isHoliday,
      isInEvent: isInEvent,
      noDisplay: noDisplay,
      activityMatched: activityMatched,
      activity: activity,
    );

    return GestureDetector(
      key: Key(
        activity?.hashCode.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
      ),
      onTap: () => onDateSelected(date),
      child: Container(
        color: isSelected
            ? (isActivity &&
                    !((activity.type == ActivityType.festival ||
                            activity.type == ActivityType.bigHoliday) &&
                        !activity.holiday))
                ? ActivityTypeData.of(activity.type)
                    .color
                    .withValues(alpha: isCurrentMonth ? 0.15 : 0.05)
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
                          color: _calculateDateColor(bg, fg, dateData)),
                    )),
                if (showBadges) ..._getBadges(bg, fg, dateData)
              ],
            ),
          ),
        ),
      ),
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
    if ((!data.isActivity || data.activity == null || data.noDisplay) &&
        !data.isInEvent) {
      return [];
    }

    final color = _calculateDateColor(bg, fg, data);
    final mt = data.activityMatched;
    const nullActivity = Activity(type: ActivityType.common);
    final firstActivity =
        mt.firstWhere((ac) => ac.name != null, orElse: () => nullActivity);

    final displayName = firstActivity != nullActivity
        ? overflowed(firstActivity.name ?? '未知', 5)
        : '';
    final displayText = Text(
      displayName,
      style: TextStyle(fontSize: 8, color: color),
    );
    final smallDisplayTextStyle = TextStyle(fontSize: 6, color: color);

    final plus = mt.length > 1;
    final plusText = plus ? '+${mt.length - 1}' : '';
    final plusElement = Positioned(
      top: 14,
      right: 8,
      child: Text(plusText, style: smallDisplayTextStyle),
    );

    List<Widget> result = [];

    switch (data.activity?.type) {
      case ActivityType.bigHoliday:
      case ActivityType.festival:
        result.addAll(data.activity!.name == null
            ? []
            : [
                Positioned(top: 32, child: displayText),
                if (data.activity?.holiday == true)
                  Positioned(
                      top: 8,
                      right: 8,
                      child: Text(
                        '休',
                        style: smallDisplayTextStyle,
                      )),
                if (plus) plusElement
              ]);
      case ActivityType.common:
        result.addAll(
            [Positioned(top: 32, child: displayText), if (plus) plusElement]);
      case ActivityType.shift:
        result.addAll([
          Positioned(
              top: 8,
              right: 8,
              child: Text(
                '班',
                style: smallDisplayTextStyle,
              )),
          if (plus) plusElement
        ]);
      case ActivityType.today:
      case ActivityType.hidden:
      case null:
    }

    if (data.isInEvent) {
      result.add(
        Positioned(
            bottom: 14,
            right: 10,
            child: Text(
              '⬤',
              style: smallDisplayTextStyle,
            )),
      );
    }

    return result;
  }

  Color? _calculateColor(DateData data, Color other) {
    if (data.noDisplay && !data.isWeekend) return other;

    if (data.activity?.isShift == true) {
      return data.activity != null
          ? ActivityTypeData.of(data.activity!.type).color
          : null;
    }

    if (data.isWeekend) {
      final result = data.activity?.holiday == true
          ? data.activity != null
              ? ActivityTypeData.of(data.activity!.type).color
              : null
          : ActivityTypeData.of(ActivityType.bigHoliday).color;
      return result;
    }

    final result =
        data.activity?.isFestival == true && data.activity?.holiday == false
            ? other
            : data.activity == null
                ? fallbackColor
                : ActivityTypeData.of(data.activity!.type).color;
    return result;
  }

  Color _calculateDateBackgroundUnselectedColor(Color bg, DateData data) {
    final op = data.isCurrentMonth ? 0.15 : 0.05;
    if (data.activity?.isShift == true) {
      return (data.activity == null
              ? fallbackColor
              : ActivityTypeData.of(data.activity!.type).color)
          .withValues(alpha: op);
    }

    if (data.isWeekend &&
        (data.activity == null || data.activity?.holiday == false)) {
      return bg;
    }
    final result = _calculateColor(data, bg) ?? bg;
    return result.withValues(alpha: op);
  }

  Color? _calculateDateBackgroundColor(Color bg, Color fg, DateData data) {
    final op = data.isCurrentMonth ? 0.8 : 0.1;
    if (!data.isSelected) {
      return _calculateDateBackgroundUnselectedColor(bg, data);
    }

    final result = _calculateColor(data, fg) ?? fallbackColor;
    return result.withValues(alpha: op);
  }

  Color? _calculateDateColor(Color bg, Color fg, DateData data) {
    const op = 0.4;

    if (data.isSelected && data.isCurrentMonth) return bg;
    if (data.activity == null && !data.isHoliday) {
      return fg.withValues(alpha: data.isCurrentMonth ? 1 : op);
    }

    final result = _calculateColor(data, fg) ?? fallbackColor;
    return data.isCurrentMonth ? result : result.withValues(alpha: op);
  }
}
