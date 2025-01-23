import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:miaomiaoswust/components/clickable.dart';
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

class _GreetingState extends State<Greeting>
    with SingleTickerProviderStateMixin {
  static const fallbackGreeting = 'Hello~';
  String? _currentGreeting;
  Timer? _timer;
  Timer? _clickTimer;
  int _clickCount = 0;
  DateTime? _lastClickTime;
  bool _isInEasterEgg = false;
  final Duration _resetThreshold = const Duration(seconds: 10);
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _timer = _timer ??
        Timer.periodic(const Duration(minutes: 1), (_) => _updateGreeting());
    _clickTimer = _clickTimer ??
        Timer.periodic(const Duration(seconds: 1), (_) {
          final now = DateTime.now();
          // 如果是第一次点击，或上次点击超过10秒，重置计数和状态
          if (_lastClickTime != null &&
              _isInEasterEgg &&
              now.difference(_lastClickTime!) >= _resetThreshold) {
            _cancelEasterEgg();
          }
        });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clickTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _cancelEasterEgg() {
    setState(() {
      _clickCount = 0;
      _isInEasterEgg = false;
      _lastClickTime = null;
    });
    _updateGreeting();
  }

  bool _generateActivityGreeting() {
    var activity = widget.activities
        .where((ac) => ac.isInActivity(DateTime.now()))
        .toList();
    if (activity.isEmpty) return false;
    if (activity.first.greetings == null) return false;
    setState(() => _currentGreeting = activity.first.greetings!.randomElement);
    return true;
  }

  void _generateTimeGreeting() {
    final now = DateTime.now();
    final w = timeGreetings.where((entry) {
      final lr = (entry['time'] as String).split('-');
      return isHourMinuteInRange(now.hmString, lr.first, lr.last, ':');
    });
    final result = w.isEmpty
        ? fallbackGreeting
        : (w.first['greetings'] as List<String>).randomElement;
    setState(() => _currentGreeting = result);
  }

  void _updateGreeting() {
    if (!_isInEasterEgg) {
      final activity = _generateActivityGreeting();
      if (!activity) _generateTimeGreeting();
    }
  }

  void _handleClick() {
    final now = DateTime.now();
    setState(() {
      _lastClickTime = now;
      _clickCount++;
    });

    if (_clickCount < 10) {
      _updateGreeting();
      return;
    }

    if (_clickCount == 40) {
      setState(() => Values.isFlipEnabled.value = true);
    } else if (_clickCount >= 45) {
      setState(() => Values.isFlipEnabled.value = false);
      _cancelEasterEgg();
      return;
    }

    String? result;
    final map = {
      10: '不要再碰我了😑',
      20: '为什么不听话😈',
      30: '你会为此付出代价的😡',
      40: '你自找的🤬',
    };
    result = map.containsKey(_clickCount) ? map[_clickCount] : null;
    if (result == null) return;

    setState(() {
      _currentGreeting = result;
      _isInEasterEgg = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentGreeting == null) {
      _updateGreeting();
    }

    // 用来修复 `emoji` 导致的文字下垂
    const strutStyle = StrutStyle(forceStrutHeight: true, height: 3.2);
    const style = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);

    final result = _currentGreeting ?? fallbackGreeting;

    return Clickable(
        onPress: () {
          if (_animationController.isAnimating ||
              _animationController.isCompleted) {
            _animationController.reset();
          }
          _animationController.forward();
          _handleClick();
        },
        child: SizedBox(
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
              )
                  .animate(controller: _animationController)
                  // .shimmer(color: Colors.grey)
                  .shakeX(hz: 3, amount: 2),
            )));
  }
}
