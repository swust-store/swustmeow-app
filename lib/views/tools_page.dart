import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:miaomiaoswust/views/duifene/duifene_homework_page.dart';
import 'package:miaomiaoswust/views/duifene/duifene_signin_settings_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage>
    with SingleTickerProviderStateMixin {
  int _currentTool = 0;
  late Map<String, Widget Function()> _tools;
  late List<String> _keys;
  final _controller = PageController();

  @override
  void initState() {
    super.initState();

    _tools = {
      '一站式': () => buildToolsColumn(context, setState, cardDetails: []),
      '对分易': () => buildToolsColumn(context, setState, cardDetails: [
            ('自动签到', '自动签到设置、通知设置', DuiFenESignInSettingsPage()),
            ('作业查询', /*'作业到期提醒'*/ '在线测试、作业快速查询', DuiFenEHomeworkPage()),
          ]),
    };
    _keys = _tools.keys.toList();

    _controller.addListener(() {
      var page = _controller.positions.isEmpty || _controller.page == null
          ? 0
          : _controller.page ?? 0;
      page = page > 0 ? page : 0;
      final diff = (page - page.toInt()).abs().toDouble();
      final result = diff >= 0.5 ? page.ceil() : page.floor();
      setState(() => _currentTool = result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
        contentPad: false,
        content: Column(
          children: [
            SizedBox(height: 48.0 + 16.0),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _keys.length,
                    itemBuilder: (context, index) => _buildTab(index),
                    separatorBuilder: (context, index) => SizedBox(width: 8.0),
                  ),
                )),
            SizedBox(height: 16.0),
            Expanded(
                flex: 20,
                child: PageView.builder(
                    controller: _controller,
                    itemCount: _keys.length,
                    itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: _tools[_keys[index]]!(),
                        )))
          ],
        ).withBackground);
  }

  Widget _buildTab(int index) {
    final c = context.theme.colorScheme;
    final active = _currentTool == index;
    final name = _tools.keys.toList()[index];

    return FTappable(
        onPress: () {
          _controller.animateToPage(index,
              duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
        },
        child: Container(
          decoration: BoxDecoration(
              color: active ? c.primary : c.secondary,
              border: Border.all(width: 1.0, color: c.border),
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: Center(
              child: Text(
            name,
            style: TextStyle(
              color: active ? c.background : c.primary,
            ),
          )),
        ));
  }
}
