import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../entity/activity.dart';
import '../../entity/activity_type.dart';
import '../../entity/date_data.dart';
import '../../utils/text.dart';

class DateCell extends HookWidget {
  const DateCell({
    super.key,
    required this.dateData,
    required this.showBadges,
    required this.bg,
    required this.fg,
  });

  final DateData dateData;
  final bool showBadges;
  final Color bg;
  final Color fg;
  static const fallbackColor = Colors.purple;

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = dateData.isCurrentMonth;
    final isWeekend = dateData.isWeekend;
    final isSelected = dateData.isSelected;
    final activityMatched = dateData.activityMatched;
    final activity = dateData.activity;
    final isActivity = activity != null && activityMatched.isNotEmpty;
    final isHoliday = (!isActivity && isWeekend) ||
        (isActivity && activity.holiday) ||
        (isWeekend && isActivity && !activity.holiday && activity.isShift);
    final noDisplay = activityMatched.where((ac) => ac.display).isEmpty ||
        activity?.type == ActivityType.hidden;
    final isInEvent = dateData.isInEvent;

    return Container(
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
                    dateData.date.day.toString(),
                    style:
                        TextStyle(color: _calculateDateColor(bg, fg, dateData)),
                  )),
              if (showBadges) ..._getBadges(bg, fg, dateData)
            ],
          ),
        ),
      ),
    );
  }

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
