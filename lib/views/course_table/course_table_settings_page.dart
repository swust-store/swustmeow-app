import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/widget.dart';
import 'package:swustmeow/views/course_table/custom_course/course_table_custom_courses_page.dart';
import 'package:swustmeow/views/course_table/course_table_display_settings_page.dart';

import '../../data/m_theme.dart';
import 'share/course_share_settings_page.dart';

class CourseTableSettingsPage extends StatelessWidget {
  const CourseTableSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '课程表设置',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: joinGap(
                  gap: 16,
                  axis: Axis.vertical,
                  widgets: [
                    if (!Values.showcaseMode)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FTile(
                          title: Text('课程表共享设置'),
                          subtitle: Text('课程表共享与权限管理'),
                          prefixIcon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: MTheme.primary2.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.userGroup,
                              color: MTheme.primary2,
                              size: 20,
                            ),
                          ),
                          suffixIcon: FaIcon(
                            FontAwesomeIcons.chevronRight,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPress: () {
                            pushTo(context, '/course_table/settings/share',
                                const CourseShareSettingsPage());
                          },
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: FTile(
                        title: Text('课程表显示设置'),
                        subtitle: Text('自定义课程表显示方式'),
                        prefixIcon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MTheme.primary2.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.palette,
                            color: MTheme.primary2,
                            size: 20,
                          ),
                        ),
                        suffixIcon: FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPress: () {
                          pushTo(context, '/course_table/settings/display',
                              const CourseTableDisplaySettingsPage());
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: FTile(
                        title: Text('自定义课程'),
                        subtitle: Text('添加、编辑、删除自定义课程'),
                        prefixIcon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MTheme.primary2.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.pencil,
                            color: MTheme.primary2,
                            size: 20,
                          ),
                        ),
                        suffixIcon: FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPress: () {
                          pushTo(
                              context,
                              '/course_table/settings/custom_courses',
                              const CourseTableCustomCoursesPage());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
