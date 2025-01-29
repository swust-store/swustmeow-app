import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        color: context.theme.colorScheme.primaryForeground,
        child: child,
      );
}
