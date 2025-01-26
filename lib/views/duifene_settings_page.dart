import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/duifene_course.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/widget.dart';

import '../data/values.dart';
import '../entity/duifene_runmode.dart';

class DuiFenESettingsPage extends StatefulWidget {
  const DuiFenESettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _DuiFenESettingsPageState();
}

class _DuiFenESettingsPageState extends State<DuiFenESettingsPage> {
  late bool _enableAutomaticSignIn;
  final FRadioSelectGroupController<DuiFenERunMode> _runModeController =
      FRadioSelectGroupController();
  List<DuiFenECourse> _courses = [];
  List<String> _selected = [];
  final FMultiSelectGroupController<String> _courseController =
      FMultiSelectGroupController();
  bool _isCourseLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadCourses();
  }

  @override
  void dispose() {
    _runModeController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    final box = BoxService.duifeneBox;
    _enableAutomaticSignIn =
        (box.get('enableAutomaticSignIn') as bool?) ?? false;

    final runMode =
        (box.get('runMode') as DuiFenERunMode?) ?? DuiFenERunMode.foreground;

    _runModeController.select(runMode, true);
    _runModeController.addListener(() async {
      final value = _runModeController.values.first;
      await box.put('runMode', value);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> _loadCourses() async {
    final box = BoxService.duifeneBox;

    _isCourseLoading = true;
    _courses = GlobalService.duifeneCourses.value;

    final selected = box.get('coursesSelected') as List<dynamic>?;
    if (selected != null) {
      _selected = selected.cast();
    } else {
      _selected = _courses.map((c) => c.courseName).toList();
      await box.put('coursesSelected', _courses);
    }

    for (final course in _selected) {
      _courseController.select(course, true);
    }

    _isCourseLoading = false;
    _courseController.addListener(() async {
      final value = _courseController.values.toList();
      await box.put('coursesSelected', value);
      setState(() => _selected = value);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    const maxLines = 100;

    return Transform.flip(
      flipX: Values.isFlipEnabled.value,
      flipY: Values.isFlipEnabled.value,
      child: FScaffold(
        contentPad: false,
        header: FHeader.nested(
          title: const Text(
            '对分易签到设置',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          prefixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.chevronLeft),
                onPress: () => Navigator.of(context).pop())
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildSettingTileGroup(context, '开关', [
                FTile(
                  title: const Text('启用全自动签到'),
                  subtitle: const Text(
                    '应用会根据下面的设置运行在前台或后台，并自动签到\n\n目前只支持签到码签到',
                    maxLines: maxLines,
                  ),
                  suffixIcon: FSwitch(
                    value: _enableAutomaticSignIn,
                    onChange: (value) async {
                      final box = BoxService.duifeneBox;
                      await box.put('enableAutomaticSignIn', value);
                      setState(() => _enableAutomaticSignIn = value);
                    },
                  ),
                ),
                FSelectMenuTile<DuiFenERunMode>(
                  title: const Text('运行模式'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListenableBuilder(
                          listenable: _runModeController,
                          builder: (context, _) => Text(
                                '当前状态：${_enableAutomaticSignIn ? _getRunModeName() : '未启用'}',
                                style: TextStyle(
                                    color: _enableAutomaticSignIn
                                        ? Colors.green
                                        : Colors.red),
                              )),
                      const SizedBox(height: 8.0),
                      Text(
                        '前台运行：只能保持应用在前台活跃状态，退出后无法继续运行\n\n后台运行：应用关闭或彻底退出（被系统杀死）仍然运行，更耗电，需要对本应用关闭电池优化并打开通知权限，此模式会在运行时生成一个无法关闭的通知消息',
                        maxLines: maxLines,
                      )
                    ],
                  ),
                  groupController: _runModeController,
                  menu: [
                    FSelectTile(
                        title: const Text('前台运行'),
                        value: DuiFenERunMode.foreground),
                    FSelectTile(
                        title: const Text('后台运行'),
                        value: DuiFenERunMode.background)
                  ],
                  enabled: _enableAutomaticSignIn,
                  autoHide: true,
                  details: Text(''),
                )
              ]),
              buildSettingTileGroup(context, '启用列表', [
                FTile(
                  title: const Text('选择需要自动签到的课程名称'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('可以多选，未打勾的不会自动签到，默认所有课程启用'),
                      const SizedBox(height: 8.0),
                      Text(
                        _selected.isNotEmpty != true
                            ? '未选择'
                            : '已选择${_selected.length}个课程',
                        maxLines: maxLines,
                      )
                    ],
                  ),
                  enabled: _enableAutomaticSignIn,
                ),
                FTile(
                  title: const Text('刷新课程列表'),
                  subtitle: const Text('点击这里以刷新'),
                  suffixIcon: FIcon(FAssets.icons.rotateCw),
                  enabled: _enableAutomaticSignIn,
                  onPress: () async {
                    setState(() => _isCourseLoading = true);
                    await GlobalService.loadDuiFenECourses();
                    setState(() => _isCourseLoading = false);
                  },
                )
              ]),
              const SizedBox(height: 8.0),
              FSelectTileGroup<String>.builder(
                  groupController: _courseController,
                  enabled: _enableAutomaticSignIn && !_isCourseLoading,
                  divider: FTileDivider.full,
                  maxHeight: 200,
                  style: context.theme.tileGroupStyle.copyWith(
                      tileStyle: context.theme.tileGroupStyle.tileStyle
                          .copyWith(
                              enabledBackgroundColor: context
                                  .theme
                                  .tileGroupStyle
                                  .tileStyle
                                  .disabledBackgroundColor)),
                  count: _courses.length,
                  tileBuilder: (context, index) {
                    final course = _courses[index];
                    return FSelectTile(
                      enabled: _enableAutomaticSignIn && !_isCourseLoading,
                      title: Text(course.courseName),
                      value: course.courseName,
                      // onChange: (value) => print(value),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  String _getRunModeName() => switch (
          _runModeController.values.firstOrNull ?? DuiFenERunMode.foreground) {
        DuiFenERunMode.foreground => '前台运行',
        DuiFenERunMode.background => '后台运行'
      };
}
