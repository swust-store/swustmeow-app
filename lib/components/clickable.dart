import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  const Clickable({super.key, required this.child, required this.onPress});

  final Widget child;
  final Function() onPress;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPress,
        child: child,
      );
}
