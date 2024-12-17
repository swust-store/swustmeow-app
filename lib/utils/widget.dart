import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/loading.dart';

extension WrapExtension on Column {
  Widget wrap(
          {required BuildContext context, double? padding, double? margin}) =>
      Column(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: children
            .map((widget) => Container(
                padding: padding == null
                    ? context.theme.style.pagePadding
                    : EdgeInsets.all(padding),
                margin: margin == null
                    ? const EdgeInsets.all(0)
                    : EdgeInsets.all(margin),
                child: widget))
            .toList(),
      );
}

List<Widget> joinPlaceholder(
    {required final double gap, required final List<Widget> widgets}) {
  if (widgets.isEmpty) return [];
  final placeholder =
      Placeholder(fallbackHeight: gap, color: Colors.transparent);
  final result = <Widget>[];
  for (final widget in widgets) {
    result.add(widget);
    result.add(placeholder);
  }
  return result.sublist(0, result.length - 1);
}

Widget buildSettingTileGroup(final BuildContext context, final String? label,
        final List<FTileMixin> children) =>
    FTileGroup(
        label: label != null
            ? Text(
                '  $label',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              )
            : const Placeholder(
                fallbackHeight: 0,
                color: Colors.transparent,
              ),
        divider: FTileDivider.full,
        style: FTileGroupStyle(
            tileStyle: context.theme.tileGroupStyle.tileStyle.copyWith(
                border: Border.all(
                    color: context.theme.colorScheme.secondary, width: 1.2),
                enabledBackgroundColor:
                    context.theme.colorScheme.primaryForeground,
                enabledHoveredBackgroundColor:
                    context.theme.colorScheme.secondary),
            enabledStyle: context.theme.tileGroupStyle.enabledStyle,
            disabledStyle: context.theme.tileGroupStyle.disabledStyle,
            errorStyle: context.theme.tileGroupStyle.errorStyle),
        children: children);

extension WidgetExtension on Widget {
  Widget loading(bool isLoading, {Widget? child}) => Stack(
        alignment: Alignment.center,
        children: [
          this,
          if (isLoading)
            Loading(
              child: child,
            )
        ],
      );
}
