import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MScaffold extends StatelessWidget {
  const MScaffold(this.child, {this.padding, this.safeArea = true, super.key});

  final Widget child;
  final double? padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) => Container(
      color: context.theme.colorScheme.background,
      padding: padding == null ? null : EdgeInsets.all(padding!),
      child: safeArea ? SafeArea(child: child) : child);
}
