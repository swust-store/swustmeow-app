import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/m_theme.dart';

class BasePage extends StatefulWidget {
  const BasePage({
    super.key,
    required this.header,
    required this.content,
    this.color,
    this.gradient,
    this.roundedBorder = true,
    this.headerPad = true,
    this.extraHeight = 0.0,
  });

  final Widget header;
  final Widget content;
  final Color? color;
  final Gradient? gradient;
  final bool roundedBorder;
  final bool headerPad;
  final double extraHeight;

  factory BasePage.color({
    required Widget header,
    required Widget content,
    bool roundedBorder = true,
    bool headerPad = true,
    double extraHeight = 0.0,
  }) =>
      BasePage(
        header: header,
        content: content,
        color: MTheme.primary2,
        roundedBorder: roundedBorder,
        headerPad: headerPad,
        extraHeight: extraHeight,
      );

  factory BasePage.gradient({
    required Widget header,
    required Widget content,
    bool roundedBorder = true,
    bool headerPad = true,
    double extraHeight = 0.0,
  }) =>
      BasePage(
        header: header,
        content: content,
        gradient: LinearGradient(
          colors: [MTheme.primary2, MTheme.primary2, Colors.white],
          transform: const GradientRotation(pi / 2),
        ),
        roundedBorder: roundedBorder,
        headerPad: headerPad,
        extraHeight: extraHeight,
      );

  @override
  State<StatefulWidget> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 88.33 +
              MTheme.radius +
              (widget.headerPad ? 16.0 + MTheme.radius : 0) +
              widget.extraHeight,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.gradient,
          ),
        ),
        Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: widget.headerPad
                    ? EdgeInsets.symmetric(horizontal: 16.0)
                    : EdgeInsets.zero,
                child: widget.header,
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: widget.roundedBorder
                      ? BorderRadius.only(
                          topLeft: Radius.circular(MTheme.radius),
                          topRight: Radius.circular(MTheme.radius),
                        )
                      : null,
                ),
                child: widget.content,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
