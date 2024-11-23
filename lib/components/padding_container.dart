import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class PaddingContainer extends StatelessWidget {
  const PaddingContainer(this.child,
      {this.padding, this.decoration, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? context.theme.style.pagePadding * 2,
        decoration: decoration,
        child: child,
      );
}
