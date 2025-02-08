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
  });

  final Widget header;
  final Widget content;
  final Color? color;
  final Gradient? gradient;
  final bool roundedBorder;
  final bool headerPad;

  factory BasePage.color({
    required Widget header,
    required Widget content,
    bool roundedBorder = true,
    bool headerPad = true,
  }) =>
      BasePage(
        header: header,
        content: content,
        color: MTheme.primary2,
        roundedBorder: roundedBorder,
        headerPad: headerPad,
      );

  factory BasePage.gradient({
    required Widget header,
    required Widget content,
    bool roundedBorder = true,
    bool headerPad = true,
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
      );

  @override
  State<StatefulWidget> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final _headerKey = GlobalKey();
  double? _headerHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _headerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _headerHeight = renderBox.size.height;
        });
      }
    });

    return Stack(
      children: [
        Container(
          key: _headerKey,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.gradient,
          ),
          width: double.infinity,
          child: SafeArea(
            bottom: widget.headerPad,
            child: Padding(
              padding: widget.headerPad
                  ? EdgeInsets.symmetric(horizontal: 16.0)
                  : EdgeInsets.zero,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [widget.header, SizedBox(height: MTheme.radius)],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedOpacity(
            opacity: _headerHeight == null ? 0 : 1,
            duration: Duration.zero,
            child: Container(
              height: size.height - (_headerHeight ?? 0) + MTheme.radius,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: widget.roundedBorder
                    ? BorderRadius.horizontal(
                        left: Radius.circular(MTheme.radius),
                        right: Radius.circular(MTheme.radius),
                      )
                    : null,
              ),
              child: widget.content,
            ),
          ),
        )
      ],
    );
  }
}
