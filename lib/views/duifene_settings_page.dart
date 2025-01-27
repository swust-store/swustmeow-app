import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/duifene_course.dart';
import 'package:miaomiaoswust/entity/duifene_sign_mode.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/widget.dart';

import '../data/values.dart';

class DuiFenESettingsPage extends StatefulWidget {
  const DuiFenESettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _DuiFenESettingsPageState();
}

class _DuiFenESettingsPageState extends State<DuiFenESettingsPage> {
  late bool _enableAutomaticSignIn;
  List<DuiFenECourse> _courses = [];
  List<DuiFenECourse> _selected = [];
  final FMultiSelectGroupController<String> _courseController =
      FMultiSelectGroupController();

  // final FRadioSelectGroupController<DuiFenESignMode> _signModeController =
  //     FRadioSelectGroupController();
  // late final FContinuousSliderController _signSecondsController;
  bool _isCourseLoading = false;

  // DuiFenESignMode _signMode = DuiFenESignMode.after;
  // int _signSeconds = 5;

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadCourses();
  }

  @override
  void dispose() {
    _courseController.dispose();
    // _signModeController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    final box = BoxService.duifeneBox;
    _enableAutomaticSignIn =
        (box?.get('enableAutomaticSignIn') as bool?) ?? false;

    // final signMode =
    //     (box?.get('signMode') as DuiFenESignMode?) ?? DuiFenESignMode.after;
    // final signSeconds = (box?.get('signSeconds') as int?) ?? 5;

    // _signMode = signMode;
    // _signModeController.select(signMode, true);
    // _signModeController.addListener(() async {
    //   final value = _signModeController.values.first;
    //   await box?.put('signMode', value);
    //   setState(() => _signMode = value);
    // });

    // _signSeconds = signSeconds;
    // 60 * factor = signSeconds => factor = signSeconds / 60
    // _signSecondsController = FContinuousSliderController(
    //   stepPercentage: 1 / 60,
    //   selection:
    //       FSliderSelection(max: signSeconds / 60, extent: (min: 0.0, max: 1.0)),
    // );
    // _signSecondsController.addListener(() async {
    //   final value = _signSecondsController.selection.offset.max;
    //   await box?.put('signSeconds', _signSeconds);
    //   setState(() => _signSeconds = (value * 60).floor());
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> _loadCourses() async {
    final box = BoxService.duifeneBox;
    final service = FlutterBackgroundService();

    _isCourseLoading = true;
    _courses = GlobalService.duifeneCourses.value;

    final selected = box?.get('coursesSelected') as List<dynamic>?;
    if (selected != null) {
      _selected = selected.cast();
    } else {
      _selected = _courses;
      await box?.put('coursesSelected', _courses);
    }

    service.invoke(
        'duifeneCourses', {'data': _selected.map((s) => s.toJson()).toList()});

    for (final course in _selected) {
      _courseController.select(course.courseName, true);
    }

    _isCourseLoading = false;
    _courseController.addListener(() async {
      final value = _courseController.values.toList();
      final selected =
          _courses.where((c) => value.contains(c.courseName)).toList();
      await box?.put('coursesSelected', selected);
      service.invoke(
          'duifeneCourses', {'data': selected.map((s) => s.toJson()).toList()});
      setState(() => _selected = selected);
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
              ValueListenableBuilder(
                  valueListenable: GlobalService.duifeneSignTotalCount,
                  builder: (context, totalCount, child) {
                    return buildSettingTileGroup(context, null, [
                      FTile(
                        title: const Text('启用全自动签到'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '运行时当检测到对分易存在签到时会自动签到，目前只支持签到码签到，启用后下次打开应用后会自动运行\n\n如需设置后台运行（即使关闭应用仍然运行）请转到「设置」页面的「后台服务」选项进行设置',
                              maxLines: maxLines,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              '总签到成功次数：$totalCount',
                              style: TextStyle(color: Colors.green),
                              maxLines: maxLines,
                            )
                          ],
                        ),
                        suffixIcon: FSwitch(
                          value: _enableAutomaticSignIn,
                          onChange: (value) async {
                            final service = FlutterBackgroundService();
                            service.invoke(value ? 'addTask' : 'removeTask',
                                {'name': 'duifene'});
                            final box = BoxService.duifeneBox;
                            await box?.put('enableAutomaticSignIn', value);
                            setState(() => _enableAutomaticSignIn = value);
                          },
                        ),
                      ),
                    ]);
                  }),
              // buildSettingTileGroup(context, '签到设置', [
              //   FSelectMenuTile<DuiFenESignMode>(
              //       title: const Text('签到时间'),
              //       groupController: _signModeController,
              //       menu: [
              //         FSelectTile(
              //             title: const Text('开始后'),
              //             value: DuiFenESignMode.after),
              //         FSelectTile(
              //             title: const Text('结束前'),
              //             value: DuiFenESignMode.before),
              //         FSelectTile(
              //             title: const Text('随机'),
              //             value: DuiFenESignMode.random)
              //       ],
              //       autoHide: true,
              //       details: ListenableBuilder(
              //           listenable: _signModeController,
              //           builder: (context, _) => Text(_getSignModeName()))),
              //   FTile(
              //     title: const Text(''),
              //     enabled: _signMode != DuiFenESignMode.random,
              //     suffixIcon: FSlider(
              //       enabled: _signMode != DuiFenESignMode.random,
              //       tooltipBuilder: (style, value) =>
              //           Text(_signSeconds == 0 ? '立刻' : '$_signSeconds秒'),
              //       description: ListenableBuilder(
              //           listenable: _signModeController,
              //           builder: (context, _) => ListenableBuilder(
              //               listenable: _signSecondsController,
              //               builder: (context, _) => Text(
              //                   '当前状态：${_getSignModeName()}${_signMode == DuiFenESignMode.random ? '' : _signSeconds == 0 ? '立刻' : '$_signSeconds秒'}'))),
              //       controller: _signSecondsController,
              //       marks: const [
              //         FSliderMark(value: 0, label: Text('立刻')),
              //         FSliderMark(value: 0.25, label: Text('15秒')),
              //         FSliderMark(value: 0.5, label: Text('30秒')),
              //         FSliderMark(value: 0.75, label: Text('45秒')),
              //         FSliderMark(value: 1, label: Text('60秒')),
              //       ],
              //     ),
              //   )
              // ]),
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
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

// String _getSignModeName() =>
//     switch (_signModeController.values.firstOrNull ?? DuiFenESignMode.after) {
//       DuiFenESignMode.after => '开始后',
//       DuiFenESignMode.before => '结束前',
//       DuiFenESignMode.random => '随机'
//     };
}
