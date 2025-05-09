import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../data/m_theme.dart';
import '../../services/boxes/soa_box.dart';

class SOASnatchCoursePage extends StatefulWidget {
  const SOASnatchCoursePage({super.key});

  @override
  State<StatefulWidget> createState() => _SOASnatchCoursePageState();
}

class _SOASnatchCoursePageState extends State<SOASnatchCoursePage> {
  late bool _enableSnatchCourse;
  late bool _enableSnatchCourseNotification;
  List<String> _courses = [];
  final FMultiSelectGroupController<String> _courseController =
      FMultiSelectGroupController();
  bool _isCourseLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    _enableSnatchCourse = (SOABox.get('enableSnatchCourse') as bool?) ?? false;
    _enableSnatchCourseNotification =
        (SOABox.get('enableSnatchCourseNotification') as bool?) ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    const maxLines = 100;

    return BasePage(
      headerPad: false,
      header: BaseHeader(title: '选课'),
      content: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.secondary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(MTheme.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MTheme.radius),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildSettingTileGroup(
                context,
                null,
                [
                  FTile(
                    title: const Text('辅助选课'),
                    subtitle: const Text(
                      '运行时会依据下面设置的课程名顺序进行选课，并持续运行自动根据课表冲突情况选择最合适的课程，直至所有课程都被选择成功，如果要选的课无法避免互相冲突，则会优先根据课程名称顺序满足\n\n如需切换前台运行（应用需要持续保持在前台）或后台运行（即使关闭应用仍然运行）请转到「设置」页面的「后台服务」选项进行设置',
                      maxLines: maxLines,
                    ),
                  ),
                  FTile(
                    title: const Text('启用选课状态通知'),
                    subtitle: const Text(
                      '启用后，辅助选课过程中会持续更新通知为当前状态，每选到一个课程后，会发送一条选课成功的通知\n\n此功能受限制于「设置」页面的「后台服务」页面中的「显示通知」选项，如果此选项关闭，会导致本选项也无法使用',
                      maxLines: maxLines,
                    ),
                    suffixIcon: FSwitch(
                      value: _enableSnatchCourseNotification,
                      onChange: (value) async {
                        final service = FlutterBackgroundService();
                        service.invoke(
                            'soaChangeSnatchCourseNotificationStatus',
                            {'isEnabled': value});
                        await SOABox.put(
                            'enableSnatchCourseNotification', value);
                        _refresh(
                                () => _enableSnatchCourseNotification = value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
