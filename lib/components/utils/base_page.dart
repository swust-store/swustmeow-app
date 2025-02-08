import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/m_theme.dart';

class BasePage extends StatefulWidget {
  const BasePage({
    super.key,
    required this.top,
    required this.bottom,
    this.color,
    this.gradient,
  });

  final Widget top;
  final Widget bottom;
  final Color? color;
  final Gradient? gradient;

  factory BasePage.color({
    required Widget top,
    required Widget bottom,
  }) =>
      BasePage(
        top: top,
        bottom: bottom,
        color: MTheme.primary2,
      );

  factory BasePage.gradient({
    required Widget top,
    required Widget bottom,
  }) =>
      BasePage(
        top: top,
        bottom: bottom,
        gradient: LinearGradient(
          colors: [MTheme.primary2, MTheme.primary2, Colors.white],
          transform: const GradientRotation(pi / 2),
        ),
      );

  @override
  State<StatefulWidget> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final _topKey = GlobalKey();
  double? _topHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _topKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _topHeight = renderBox.size.height;
        });
      }
    });

    return Stack(
      children: [
        Container(
          key: _topKey,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.gradient,
          ),
          width: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                shrinkWrap: true,
                children: [widget.top, SizedBox(height: MTheme.radius)],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedOpacity(
            opacity: _topHeight == null ? 0 : 1,
            duration: Duration.zero,
            child: Container(
              height: size.height - (_topHeight ?? 0) + MTheme.radius,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(MTheme.radius),
                  right: Radius.circular(MTheme.radius),
                ),
              ),
              child: widget.bottom,
            ),
          ),
        )
      ],
    );
  }
}
