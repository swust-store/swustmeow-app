import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  const Clickable({super.key, required this.child, required this.onClick});

  final Widget child;
  final Function() onClick;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onClick,
        child: child,
      );
}
