import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MScaffold extends StatelessWidget {
  const MScaffold(this.child,
      {this.padding,
      this.safeArea = true,
      this.safeTop = true,
      this.safeBottom = true,
      super.key});

  final Widget child;
  final double? padding;
  final bool safeArea;
  final bool safeTop;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) => Container(
      color: context.theme.colorScheme.background,
      padding: padding == null ? null : EdgeInsets.all(padding!),
      child: safeArea
          ? SafeArea(
              top: safeTop,
              bottom: safeBottom,
              child: child,
            )
          : child);
}
