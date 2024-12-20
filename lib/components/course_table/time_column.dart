import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../utils/time.dart';

class TimeColumn extends StatefulWidget {
  const TimeColumn({super.key, required this.number, required this.time});

  final int number;
  final String time;

  @override
  State<StatefulWidget> createState() => _TimeColumnState();
}

class _TimeColumnState extends State<TimeColumn> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = _timer ??
        Timer.periodic(const Duration(seconds: 1),
            (_) => setState(() => _currentTime = DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const splitPattern = ':';
    final splitRes = widget.time.split('\n');
    final inRange = isHourMinuteInRange(
        _currentTime.hmString, splitRes[0], splitRes[1], splitPattern);
    final style = TextStyle(
        color: inRange ? Colors.lightBlue : context.theme.colorScheme.primary);

    return SizedBox(
      width: 34,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
            ),
            Text(widget.number.toString(),
                textAlign: TextAlign.center,
                style: style.copyWith(fontSize: 10)),
            Text(
              widget.time,
              textAlign: TextAlign.center,
              style: style.copyWith(fontSize: 8),
            )
          ],
        ),
      ),
    );
  }
}
