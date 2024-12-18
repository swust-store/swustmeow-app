import 'dart:async';

import 'package:flutter/material.dart';

class TimeNotifier extends ValueNotifier<DateTime> {
  TimeNotifier({this.duration}) : super(DateTime.now()) {
    _timer = Timer.periodic(duration ?? const Duration(seconds: 1),
        (timer) => value = DateTime.now());
  }

  final Duration? duration;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
