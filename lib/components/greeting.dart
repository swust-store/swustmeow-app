import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/utils/list.dart';

import '../data/greetings.dart';
import '../entity/activity/activity.dart';
import '../utils/time.dart';

class Greeting extends StatefulWidget {
  const Greeting({super.key, required this.activities});

  final List<Activity> activities;

  @override
  State<StatefulWidget> createState() => _GreetingState();
}

class _GreetingState extends State<Greeting> {
  static const fallbackGreeting = 'Hello~';
  String? _currentGreeting;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = _timer ??
        Timer.periodic(
            const Duration(minutes: 1), (_) => _updateGreeting(DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _generateActivityGreeting() {
    var activity =
        widget.activities.where((ac) => ac.isInActivity(Values.now)).toList();
    if (activity.isEmpty) return false;
    if (activity.first.greetings == null) return false;
    setState(() => _currentGreeting = activity.first.greetings!.randomElement);
    return true;
  }

  void _generateTimeGreeting(DateTime currentTime) {
    final w = timeGreetings.where((entry) {
      final lr = (entry['time'] as String).split('-');
      return isHourMinuteInRange(currentTime.hmString, lr.first, lr.last, ':');
    });
    final result = w.isEmpty
        ? fallbackGreeting
        : (w.first['greetings'] as List<String>).randomElement;
    setState(() => _currentGreeting = result);
  }

  void _updateGreeting(DateTime currentTime) {
    final activity = _generateActivityGreeting();
    if (!activity) _generateTimeGreeting(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    if (_currentGreeting == null) {
      _updateGreeting(Values.now);
    }

    // 用来修复 `emoji` 导致的文字下垂
    const strutStyle = StrutStyle(forceStrutHeight: true, height: 3.2);
    const style = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);

    final result = _currentGreeting ?? fallbackGreeting;

    return SizedBox(
        height: 60,
        child: Align(
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              Text(
                result,
                style: style.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = Colors.black54),
                strutStyle: strutStyle,
              ),
              Text(
                result,
                style: style,
                strutStyle: strutStyle,
              )
            ],
          ),
        ));
  }
}
