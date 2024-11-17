import 'package:flutter/material.dart';

import '../constants.dart';

class PaddingContainer extends StatelessWidget {
  const PaddingContainer(this.child, {this.padding, this.decoration, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? Constants(context).padding,
        decoration: decoration,
        child: child,
      );
}
