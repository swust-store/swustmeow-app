import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

extension WrapExtension on Column {
  Widget wrap({required BuildContext context, double? padding, double? margin}) => Column(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: children
            .map((widget) => Container(
                padding: padding == null ? context.theme.style.pagePadding : EdgeInsets.all(padding),
                margin: margin == null ? const EdgeInsets.all(0) : EdgeInsets.all(margin),
                child: widget))
            .toList(),
      );
}
