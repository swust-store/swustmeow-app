import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  const AnimatedText(
      {super.key, required this.textList, this.duration, this.textStyle});

  final List<String> textList;
  final Duration? duration;
  final TextStyle? textStyle;

  @override
  State<StatefulWidget> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  late Timer _timer;
  int index = 0;

  void _startTimer(void Function(Timer timer) onSec) {
    final dur = widget.duration ?? const Duration(seconds: 1);
    _timer = Timer.periodic(dur, (Timer timer) => onSec(timer));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _startTimer((Timer timer) {
      setState(() => index += 1);
      if (index == widget.textList.length) setState(() => index = 0);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      Text(widget.textList[index], style: widget.textStyle);
}
