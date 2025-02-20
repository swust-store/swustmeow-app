import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/router.dart';

import 'course_share_settings_page.dart';

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
            FTile(
              title: Text('课程表共享设置'),
              subtitle: Text('课程表共享与权限管理'),
              prefixIcon: FaIcon(FontAwesomeIcons.users),
              suffixIcon: FaIcon(FontAwesomeIcons.chevronRight),
              onPress: () {
                pushTo(context, const CourseShareSettingsPage());
              },
            ),
            // 这里可以添加其他课程表相关的设置项
          ],
        ),
      ),
    );
  }
}
