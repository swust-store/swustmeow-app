import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/divider_with_text.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/entity/duifene/duifene_course.dart';
import 'package:swustmeow/entity/duifene/duifene_homework.dart';
import 'package:swustmeow/entity/duifene/duifene_test.dart';
import 'package:swustmeow/entity/duifene/duifene_test_base.dart';
import 'package:swustmeow/utils/time.dart';

import '../../components/utils/empty.dart';
import '../../data/m_theme.dart';
import '../../services/global_service.dart';
import '../../services/value_service.dart';
import '../../utils/status.dart';

class DuiFenEHomeworkPage extends StatefulWidget {
  const DuiFenEHomeworkPage({super.key});

  @override
  State<StatefulWidget> createState() => _DuiFenEHomeworkPageState();
}

class _DuiFenEHomeworkPageState extends State<DuiFenEHomeworkPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late bool _isLogin;
  late FPopoverController _selectDisplayModeController;
  DisplayMode _currentDisplayMode = DisplayMode.sortedByEndDate;
  Map<DuiFenECourse, List<DuiFenETest>> _tests = {};
  Map<DuiFenECourse, List<DuiFenEHomework>> _homeworks = {};

  @override
  void initState() {
    super.initState();
    _isLogin = GlobalService.duifeneService?.isLogin == true;
    if (_isLogin) {
      _load().then((_) => _refresh(() => _isLoading = false));
    } else {
      _isLoading = false;
    }
    _selectDisplayModeController = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _selectDisplayModeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _loadTests();
    await _loadHomeworks();
  }

  Future<void> _loadTests() async {
    final courses = GlobalService.duifeneCourses.value;

    Map<DuiFenECourse, List<DuiFenETest>> result = {};
    for (final course in courses) {
      final listResult = await GlobalService.duifeneService?.getTests(course);
      if (listResult == null || listResult.status != Status.ok) continue;

      final list = listResult.value!;
      result[course] = list;
    }

    _refresh(() => _tests = result);
  }

  Future<void> _loadHomeworks() async {
    final courses = GlobalService.duifeneCourses.value;

    Map<DuiFenECourse, List<DuiFenEHomework>> result = {};
    for (final course in courses) {
      final listResult =
          await GlobalService.duifeneService?.getHomeworks(course);
      if (listResult == null || listResult.status != Status.ok) continue;

      final list = listResult.value!;
      result[course] = list;
    }

    _refresh(() => _homeworks = result);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
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
            '对分易作业',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          suffixIcons: [
            FPopover(
              controller: _selectDisplayModeController,
              popoverBuilder: (context, style, _) =>
                  _buildSelectDisplayModePopover(),
              child: FTappable(
                onPress: () async {
                  if (!_isLogin || _isLoading) return;
                  await _selectDisplayModeController.toggle();
                },
                child: FaIcon(
                  FontAwesomeIcons.arrowDownWideShort,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            // SizedBox(),
            IconButton(
              onPressed: () async {
                if (!_isLogin || _isLoading) return;
                _refresh(() => _isLoading = true);
                await GlobalService.loadDuiFenECourses();
                await _load();
                _refresh(() => _isLoading = false);
              },
              icon: FaIcon(
                FontAwesomeIcons.rotateRight,
                color: Colors.white,
                size: 20,
              ),
            ),
            // SizedBox(),
            // FHeaderAction(
            //     icon: FIcon(FAssets.icons.settings,
            //         color: _isLogin && !_isLoading ? null : Colors.grey),
            //     onPress: () {
            //       if (!_isLogin || _isLoading) return;
            //       pushTo(context, const DuiFenEHomeworkSettingsPage());
            //     })
          ],
        ),
        content: _isLogin
            ? Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 32.0),
                child: FTabs(tabs: [
                  FTabEntry(
                    label: const Text('在线练习'),
                    content: Expanded(
                      child: _buildPage(_tests),
                    ),
                  ),
                  FTabEntry(
                    label: const Text('作业'),
                    content: Expanded(
                      child: _buildPage(_homeworks),
                    ),
                  ),
                  // FTabEntry(
                  //     label: const Text('设置'),
                  //     content: DuiFenEHomeworkSettingsPage())
                ]),
              )
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '未登录对分易',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    Text(
                      '请转到「设置」页面的「账号管理」选项进行登录',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPage(Map<DuiFenECourse, List<DuiFenETestBase>> map) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: MTheme.primary2,
        ),
      );
    }

    if (_currentDisplayMode == DisplayMode.categorizedByCourseName) {
      return ListView.builder(
        itemCount: map.length,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final course = map.keys.toList()[index];
          var tests = map[course]!;

          if (tests.isEmpty) {
            return const Empty();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DividerWithText(
                crossAxisAlignment: CrossAxisAlignment.start,
                child: Text(
                  course.courseName,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12.0),
              _buildCard(tests),
              const SizedBox(height: 12.0),
            ],
          );
        },
      );
    }

    if (_currentDisplayMode == DisplayMode.sortedByEndDate) {
      final now = DateTime.now();
      List<DuiFenETestBase> tests = [];

      for (final key in map.keys) {
        final list = map[key]!;
        tests.addAll(list);
      }

      final notEnded = tests.where((t) => now < t.endTime).toList()
        ..sort((a, b) => (a.endTime - now).compareTo(b.endTime - now));
      final ended = tests.where((t) => now >= t.endTime).toList()
        ..sort((a, b) => (now - a.endTime).compareTo(now - b.endTime));

      tests = notEnded + ended;

      return _buildCard(tests);
    }

    return const Empty();
  }

  Widget _buildCard(List<DuiFenETestBase> tests) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => SizedBox(height: 16.0),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final now = DateTime.now();
        final test = tests[index];
        final style = TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black.withValues(alpha: 0.6),
        );
        final gone = now >= test.endTime;
        final diff = test.endTime - now;

        final days = diff.inDays;
        final hours = diff.inHours % 24;
        final minutes = diff.inMinutes % 60;
        final timeLeft = [
          '剩余：',
          if (days > 0) '${days.padL2}天${hours.padL2}小时${minutes.padL2}分钟',
          if (days == 0) '${hours.padL2}小时${minutes.padL2}分钟！',
          if (days == 0 && hours == 0) '${minutes.padL2}分钟！！'
        ].join();
        final emergencyValue =
            (diff.inMinutes >= 7200 ? 7200 : diff.inMinutes) / 7200;

        return Opacity(
          opacity: !gone ? 1 : 0.5,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: MTheme.border),
              borderRadius: BorderRadius.circular(MTheme.radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.name.trim(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        [
                          if (test.beginTime != null)
                            '开始：${test.beginTime!.string}',
                          '结束：${test.endTime.string}',
                        ].join('\n'),
                        style: style.copyWith(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (!gone)
                        Text(
                          timeLeft,
                          style: style.copyWith(
                            color: Colors.red.withValues(
                              red: 1,
                              green: emergencyValue,
                              blue: emergencyValue,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                Text(
                  test.finished
                      ? test is DuiFenETest
                          ? '${test.score}分'
                          : '已完成'
                      : '未完成',
                  style: TextStyle(
                      fontSize: 14,
                      color: (test.finished
                          ? context.theme.colorScheme.primary
                              .withValues(alpha: 0.5)
                          : Colors.red),
                      fontFeatures: [FontFeature.tabularFigures()]),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectDisplayModePopover() {
    return SizedBox(
      width: 170,
      child: FTileGroup.builder(
        divider: FTileDivider.full,
        count: DisplayMode.values.length,
        tileBuilder: (context, index) {
          final value = DisplayMode.values[index];
          return FTile(
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(value.description),
            ),
            prefixIcon: _currentDisplayMode == value
                ? FIcon(FAssets.icons.check, size: 16)
                : null,
            onPress: () async {
              await _selectDisplayModeController.hide();
              _refresh(() => _currentDisplayMode = value);
            },
          );
        },
      ),
    );
  }
}

enum DisplayMode {
  sortedByEndDate('按结束时间排序'),
  categorizedByCourseName('按课程名称分类');

  final String description;

  const DisplayMode(this.description);
}
