import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  const Clickable(this.child, {required this.onPress, super.key});

  final Widget child;
  final Function() onPress;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPress,
        child: child,
      );
}
