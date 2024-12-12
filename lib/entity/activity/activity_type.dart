import 'package:flutter/material.dart';
import 'package:forui/assets.dart';

enum ActivityType {
  today(
      Colors.blue,
      5,
      SvgAsset(
        'forui_assets',
        'circle',
        'assets/icons/circle.svg',
      )),
  common(
      Colors.orange,
      4,
      SvgAsset(
        'forui_assets',
        'square-chart-gantt',
        'assets/icons/square-chart-gantt.svg',
      )),
  shift(
      Colors.red,
      3,
      SvgAsset(
        'forui_assets',
        'calendar-x',
        'assets/icons/calendar-x.svg',
      )),
  festival(
      Color(0xFF2E7D32),
      2,
      SvgAsset(
        'forui_assets',
        'calendar-fold',
        'assets/icons/calendar-fold.svg',
      )),
  bigHoliday(
      Color(0xFF66BB6A),
      1,
      SvgAsset(
        'forui_assets',
        'sparkles',
        'assets/icons/sparkles.svg',
      )),
  hidden(Colors.black, 0, null);

  final Color color;
  final int priority;
  final SvgAsset? icon;

  const ActivityType(this.color, this.priority, this.icon);
}
