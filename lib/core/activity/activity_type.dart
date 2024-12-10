import 'dart:ui';

import 'package:flutter/material.dart';

enum ActivityType {
  common(Colors.orange),
  festival(Colors.green),
  shift(Colors.red);

  final Color color;

  const ActivityType(this.color);
}
