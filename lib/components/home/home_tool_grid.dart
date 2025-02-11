import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/utils/router.dart';

import '../../views/tools_page.dart';
import '../tool_grid.dart';

class HomeToolGrid extends StatefulWidget {
  const HomeToolGrid({super.key, required this.padding});

  final double padding;

  @override
  State<StatefulWidget> createState() => _HomeToolGridState();
}

class _HomeToolGridState extends State<HomeToolGrid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const columns = 5;
    const maxRows = 3;
    final displayToolsLength = columns * 2 - 1;
    final displayTools = Values.tools.where((tool) {
      final (_, _, _, _, display) = tool;
      return display;
    }).toList();
    List<(String, IconData, Color, StatefulWidget Function(), bool)>  result = [];
    for (final tool in displayTools) {
      if (result.length == displayToolsLength) break;
      result.add(tool);
    }

    final tools = [
      ...result,
      (
        '更多',
        FontAwesomeIcons.ellipsis,
        Colors.purple,
        () => ToolsPage(padding: widget.padding),
        true
      )
    ];

    final size = MediaQuery.of(context).size.width;
    final dimension = (size - (widget.padding * 2)) / columns;
    final rows = (tools.length / columns).ceil();

    return SizedBox(
      height: dimension * (rows > maxRows ? maxRows : rows),
      child: ToolGrid(
        columns: columns,
        children: tools.map(
          (data) {
            final (name, icon, color, builder, _) = data;
            return FTappable(
              onPress: () {
                pushTo(context, builder(), pushInto: true);
                setState(() {});
              },
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      icon,
                      color: color.withValues(alpha: 0.8),
                      size: 26,
                    ),
                    SizedBox(height: 4.0),
                    AutoSizeText(
                      name,
                      minFontSize: 6,
                      maxFontSize: 12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
