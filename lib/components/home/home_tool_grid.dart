import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/duifene/duifene_homework_page.dart';
import 'package:swustmeow/views/duifene/duifene_signin_settings_page.dart';
import 'package:swustmeow/views/soa/soa_leaves_page.dart';
import 'package:swustmeow/views/soa/soa_snatch_course_page.dart';

import '../tool_grid.dart';

class HomeToolGrid extends StatefulWidget {
  const HomeToolGrid({super.key, required this.padding});

  final double padding;

  @override
  State<StatefulWidget> createState() => _HomeToolGridState();
}

class _HomeToolGridState extends State<HomeToolGrid> {
  final tools = [
    (
      '选课抢课',
      FontAwesomeIcons.bookOpen,
      Colors.blue,
      () => SOASnatchCoursePage()
    ),
    (
      '请假',
      FontAwesomeIcons.solidCalendarPlus,
      Colors.blue,
      () => SOALeavesPage()
    ),
    (
      '对分易自动签到',
      FontAwesomeIcons.locationDot,
      Colors.orange,
      () => DuiFenESignInSettingsPage()
    ),
    (
      '对分易作业',
      FontAwesomeIcons.solidFile,
      Colors.orange,
      () => DuiFenEHomeworkPage()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const columns = 4;
    const maxRows = 3;
    final size = MediaQuery.of(context).size.width;
    final dimension = (size - (widget.padding * 2)) / columns;
    final rows = (tools.length / columns).ceil();

    return SizedBox(
      height: dimension * (rows > maxRows ? maxRows : rows),
      child: ToolGrid(
          columns: columns,
          children: tools.map((data) {
            final (name, icon, color, builder) = data;
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
          }).toList()),
    );
  }
}
