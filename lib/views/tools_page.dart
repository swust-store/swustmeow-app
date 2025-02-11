import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/values.dart';

import '../components/tool_grid.dart';
import '../services/value_service.dart';
import '../utils/router.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key, required this.padding});

  final double padding;

  @override
  State<StatefulWidget> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  List<(String, IconData, Color, StatefulWidget Function(), bool)> _tools = [];

  @override
  void initState() {
    super.initState();
    _tools = Values.tools;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '工具',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 4),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildGrid(),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    const columns = 4;

    return ToolGrid(
      columns: columns,
      children: _tools.map(
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
    );
  }
}
