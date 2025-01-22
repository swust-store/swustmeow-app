import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key, required this.child, this.gap = 8.0});

  final Widget child;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      const Expanded(child: Divider()),
      SizedBox(
        width: gap,
      ),
      child,
      SizedBox(
        width: gap,
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
