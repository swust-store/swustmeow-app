import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/types.dart';
import 'package:swustmeow/utils/router.dart';

import '../../utils/common.dart';
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
      final (_, _, _, _, _, display) = tool;
      return display;
    }).toList();
    List<ToolEntry> result = [];
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
        () => null,
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
            final (name, icon, color, builder, serviceGetter, _) = data;
            final service = serviceGetter();

            buildChild(bool isLogin) => FTappable(
                  onPress: () {
                    if (!isLogin) {
                      showErrorToast('未登录${service?.name}');
                      return;
                    }
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
                          color: isLogin
                              ? color.withValues(alpha: 0.9)
                              : Colors.grey.withValues(alpha: 0.4),
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

            final isLogin = service == null ? true : service.isLogin;
            return service != null
                ? ValueListenableBuilder(
                    valueListenable: service.isLoginNotifier,
                    builder: (context, isLogin, _) {
                      return buildChild(isLogin);
                    },
                  )
                : buildChild(isLogin);
          },
        ).toList(),
      ),
    );
  }
}
