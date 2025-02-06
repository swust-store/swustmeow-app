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
  final _topKey = GlobalKey();
  double? _topHeight;
  static const radius = 16.0;

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
                children: [widget.top, SizedBox(height: radius)],
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
              height: size.height - (_topHeight ?? 0) + radius,
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
          ),
        )
      ],
    );
  }
}
