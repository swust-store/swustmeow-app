import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  const BasePage(
      {super.key,
      required this.top,
      required this.bottom,
      this.color,
      this.gradient});

  final Widget top;
  final Widget bottom;
  final Color? color;
  final Gradient? gradient;

  @override
  State<StatefulWidget> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final topKey = GlobalKey();
  double topHeight = 0.0;
  static const radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = topKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          topHeight = renderBox.size.height;
        });
      }
    });

    return Stack(
      children: [
        Container(
          key: topKey,
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
                children: [widget.top, SizedBox(height: radius)],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: size.height - topHeight + radius,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(radius),
                right: Radius.circular(radius),
              ),
            ),
            child: widget.bottom,
          ),
        )
      ],
    );
  }
}
