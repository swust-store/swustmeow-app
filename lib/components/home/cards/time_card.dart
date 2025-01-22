import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeCard extends StatefulWidget {
  const TimeCard({super.key, required this.cardStyle});

  final FCardStyle cardStyle;

  @override
  State<StatefulWidget> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  Timer? _timer;
  DateTime _currentTime = Values.now;

  String? _hitokoto;
  bool _loadingHitokoto = true;

  @override
  void initState() {
    super.initState();
    _loadHitokoto();
    _timer = _timer ??
        Timer.periodic(const Duration(seconds: 1),
            (_) => setState(() => _currentTime = DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadHitokoto() async {
    final prefs = await SharedPreferences.getInstance();
    final res = prefs.getString('hitokoto');
    setState(() {
      _hitokoto = res;
      _loadingHitokoto = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FCard(
      style: widget.cardStyle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_currentTime.hour.padL2}:${_currentTime.minute.padL2}:${_currentTime.second.padL2}',
                style: const TextStyle(
                    fontSize: 24, fontFeatures: [FontFeature.tabularFigures()]),
              ),
              Text(
                ' ${_currentTime.year}年${_currentTime.month.padL2}月${_currentTime.day.padL2}日',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()]),
              )
            ],
          ),
        ],
      ),
    );
  }
}
