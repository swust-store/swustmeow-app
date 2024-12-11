import 'package:flutter/material.dart';
import 'package:forui/assets.dart';

enum ActivityType {
  common(
      Colors.orange,
      3,
      SvgAsset(
        'forui_assets',
        'square-chart-gantt',
        'assets/icons/square-chart-gantt.svg',
      )),
  shift(
      Colors.red,
      2,
      SvgAsset(
        'forui_assets',
        'calendar-x',
        'assets/icons/calendar-x.svg',
      )),
  festival(
      Colors.green,
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
