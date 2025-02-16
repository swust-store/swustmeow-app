import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:swustmeow/utils/router.dart';

import '../components/utils/double_column.dart';

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

List<Widget> joinGap(
    {required final double gap,
    required final Axis axis,
    required final List<Widget> widgets}) {
  if (widgets.isEmpty) return [];
  final sizedBox = switch (axis) {
    Axis.horizontal => SizedBox(width: gap),
    Axis.vertical => SizedBox(height: gap),
  };
  final result = <Widget>[];
  for (final widget in widgets) {
    result.add(widget);
    result.add(sizedBox);
  }
  return result.sublist(0, result.length - 1);
}

Widget buildSettingTileGroup(
  final BuildContext context,
  final String? label,
  final List<FTileMixin> children,
) {
  return FTileGroup(
    label: label != null
        ? Text(
            '  $label',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          )
        : const Placeholder(
            fallbackHeight: 0,
            color: Colors.transparent,
          ),
    divider: FTileDivider.none,
    style: context.theme.tileGroupStyle.copyWith(
      borderColor: Colors.transparent,
      tileStyle: context.theme.tileGroupStyle.tileStyle.copyWith(
        border: Border.all(color: Colors.transparent, width: 0),
        borderRadius: BorderRadius.zero,
      ),
    ),
    children: children,
  );
}

Widget buildToolsColumn(BuildContext context, Function(Function()) setState,
    {required List<(String, String?, Widget)> cardDetails}) {
  final left = cardDetails.where((s) => cardDetails.indexOf(s) % 2 == 0);
  final right = cardDetails.where((s) => cardDetails.indexOf(s) % 2 == 1);

  Widget buildCard((String, String?, Widget) pack) {
    final (t, s, w) = pack;
    return FTappable(
      onPress: () {
        pushTo(context, w, pushInto: true);
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
            color: /*Values.isDarkMode
                ? context.theme.colorScheme.primaryForeground
                :*/
                null,
            border:
                Border.all(width: 1.0, color: context.theme.colorScheme.border),
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          children: [
            Text(t, style: TextStyle(fontSize: 16)),
            if (s != null)
              Text(s, style: TextStyle(fontSize: 14, color: Colors.grey))
          ],
        ),
      ),
    );
  }

  return DoubleColumn(
      left: left.map((p) => buildCard(p)).toList(),
      right: right.map((p) => buildCard(p)).toList());
}

Widget buildShowcaseWidget({
  required GlobalKey key,
  required String title,
  required String description,
  required Widget child,
  double? height,
  double? width,
  EdgeInsets? padding,
}) {
  return Showcase(
    key: key,
    title: title,
    description: description,
    titleAlignment: Alignment.centerLeft,
    descriptionAlignment: Alignment.centerLeft,
    titlePadding: EdgeInsets.fromLTRB(12, 6, 12, 3),
    descriptionPadding: EdgeInsets.fromLTRB(12, 3, 12, 6),
    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    descTextStyle: TextStyle(fontSize: 14, letterSpacing: 0),
    scaleAnimationCurve: Curves.easeInOutQuad,
    scaleAnimationDuration: Duration(milliseconds: 300),
    targetPadding: padding ?? EdgeInsets.zero,
    child: SizedBox(
      height: height,
      width: width,
      child: child,
    ),
  );
}
