import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/services/boxes/course_box.dart';
import 'package:swustmeow/services/value_service.dart';

import '../../data/m_theme.dart';

class CourseTableDisplaySettingsPage extends StatefulWidget {
  const CourseTableDisplaySettingsPage({super.key});

  @override
  State<CourseTableDisplaySettingsPage> createState() =>
      _CourseTableDisplaySettingsPageState();
}

class _CourseTableDisplaySettingsPageState
    extends State<CourseTableDisplaySettingsPage> {
  late bool _showSubCourseName;
  late bool _showRedBorderForConflict;
  late bool _showStarForMultiCandidates;

  @override
  void initState() {
    super.initState();
    _showSubCourseName = CourseBox.get('showSubCourseName') as bool? ?? false;
    _showRedBorderForConflict =
        CourseBox.get('showRedBorderForConflict') as bool? ?? true;
    _showStarForMultiCandidates =
        CourseBox.get('showStarForMultiCandidates') as bool? ?? false;
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
            '课程表显示设置',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: _buildList(),
      ),
    );
  }

  Widget _buildList() {
    final maxLines = 100;
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        FTileGroup(
          label: Text('显示样式'),
          children: [
            FTile(
              title: Text('优先显示子课程名称'),
              subtitle: Text(
                '多用于实验课，优先使用子课程名称（项目名称）显示，而不是主要课程名称（课程的总名称）',
                maxLines: maxLines,
              ),
              prefixIcon: Container(
                width: 36,
                height: 36,
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MTheme.primary2.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  FontAwesomeIcons.textWidth,
                  color: MTheme.primary2,
                  size: 20,
                ),
              ),
              suffixIcon: FSwitch(
                value: _showSubCourseName,
                onChange: (value) async {
                  await CourseBox.put('showSubCourseName', value);
                  setState(() => _showSubCourseName = value);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        FTileGroup(
          label: Text('课表提示'),
          divider: FTileDivider.full,
          children: [
            FTile(
              title: Text('重课显示红框'),
              subtitle: Text(
                '两个或多个课程冲突（不同课程在同一周、同一天、同一节）时显示红色边框提示',
                maxLines: maxLines,
              ),
              prefixIcon: Container(
                width: 36,
                height: 36,
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MTheme.primary2.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  color: MTheme.primary2,
                  size: 20,
                ),
              ),
              suffixIcon: FSwitch(
                value: _showRedBorderForConflict,
                onChange: (value) async {
                  await CourseBox.put('showRedBorderForConflict', value);
                  setState(() => _showRedBorderForConflict = value);
                },
              ),
            ),
            FTile(
              title: Text('多候选课程显示星号'),
              subtitle: Text(
                '在具有多个候选课程的课程名称前显示星号（*）标记，表示当前课程所在的位置存在多个课程',
                maxLines: maxLines,
              ),
              prefixIcon: Container(
                width: 36,
                height: 36,
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MTheme.primary2.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  FontAwesomeIcons.asterisk,
                  color: MTheme.primary2,
                  size: 20,
                ),
              ),
              suffixIcon: FSwitch(
                value: _showStarForMultiCandidates,
                onChange: (value) async {
                  await CourseBox.put('showStarForMultiCandidates', value);
                  setState(() => _showStarForMultiCandidates = value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
