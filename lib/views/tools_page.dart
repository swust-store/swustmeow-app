import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/widget.dart';
import 'package:swustmeow/views/duifene/duifene_homework_page.dart';
import 'package:swustmeow/views/duifene/duifene_signin_settings_page.dart';
import 'package:swustmeow/views/soa/soa_leaves_page.dart';
import 'package:swustmeow/views/soa/soa_snatch_course_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  late Map<String, Widget Function()> _tools;

  @override
  void initState() {
    super.initState();

    _tools = {
      '一站式': () => buildToolsColumn(context, setState, cardDetails: [
            ('自动抢课', '一键抢课、自动抢课设置', SOASnatchCoursePage()),
            ('请假', '一键请假、模板保存', SOALeavesPage())
          ]),
      '对分易': () => buildToolsColumn(context, setState, cardDetails: [
            ('自动签到', '自动签到设置、通知设置', DuiFenESignInSettingsPage()),
            ('作业查询', /*'作业到期提醒'*/ '在线测试、作业快速查询', DuiFenEHomeworkPage()),
          ]),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      contentPad: false,
      content: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: FTabs(
            scrollable: true,
            tabs: _tools.keys.map((toolName) {
              final buildTool = _tools[toolName]!;
              return FTabEntry(label: Text(toolName), content: buildTool());
            }).toList(),
          ),
        ),
      ).withBackground,
    );
  }
}
