import 'dart:ui';

import 'package:flutter/material.dart';

enum ActivityType {
  common(Colors.orange, 3),
  shift(Colors.red, 2),
  festival(Colors.green, 1),
  hidden(Colors.black, 0);

  final Color color;
  final int priority;

  const ActivityType(this.color, this.priority);
}
