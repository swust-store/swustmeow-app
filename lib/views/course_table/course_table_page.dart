import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'package:swustmeow/components/header_selector.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/services/boxes/course_box.dart';
import 'package:swustmeow/services/global_keys.dart';
import 'package:swustmeow/utils/courses.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../components/course_table/course_table.dart';
import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../entity/soa/course/courses_container.dart';
import '../../services/global_service.dart';
import '../../services/value_service.dart';
import '../../utils/common.dart';
import 'course_table_settings_page.dart';

class CourseTablePage extends StatefulWidget {
  const CourseTablePage({
    super.key,
    required this.containers,
    required this.currentContainer,
    required this.activities,
  });

  final List<CoursesContainer> containers;
  final CoursesContainer currentContainer;
  final List<Activity> activities;

  @override
  State<StatefulWidget> createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage>
    with SingleTickerProviderStateMixin {
  late List<CoursesContainer> _containers;
  late CoursesContainer _currentContainer;
  bool _isLoading = false;
  late AnimationController _refreshAnimationController;
  bool _isFirstTime = false;
  bool _hasStartedShowcase = false;
  late BuildContext _showcaseContext;
  late List<GlobalKey> _showcaseKeys;

  @override
  void initState() {
    super.initState();
    _containers = widget.containers;
    _currentContainer = widget.currentContainer;
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _isFirstTime = CourseBox.get('isFirstTime') ?? true;

    _showcaseKeys = [
      GlobalKeys.showcaseCourseTableHeaderKey,
      GlobalKeys.showcaseCourseTableSettingsKey,
      GlobalKeys.showcaseCourseTableRefreshKey,
    ];
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  String _parseDisplayString(String term) {
    if (!term.contains('-') || term.split('-').length != 3) return '';
    final [s, e, t] = term.split('-');
    final now = DateTime.now();
    final (_, _, w) =
        GlobalService.termDates.value[term]?.value ?? (now, now, -1);
    final week = w > 0 ? '($w周)' : '';
    return '$s-$e-$t$week';
  }

  @override
  Widget build(BuildContext context) {
    final userId = GlobalService.soaService?.currentAccount?.account;
    final containers = _containers +
        ValueService.sharedContainers
            .where((c) => c.sharerId != userId)
            .toList();
    final titleStyle = TextStyle(fontSize: 14, color: Colors.white);

    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: ShowCaseWidget(
          disableBarrierInteraction: true,
          globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
                left: 16,
                bottom: 16,
                child: Padding(
                  padding: EdgeInsets.all(MTheme.radius),
                  child: ElevatedButton(
                    onPressed: () {
                      CourseBox.put('isFirstTime', false);
                      ShowCaseWidget.of(showcaseContext).dismiss();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MTheme.primary2),
                    child: Text('跳过', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
          globalTooltipActionConfig: TooltipActionConfig(
            position: TooltipActionPosition.outside,
            alignment: MainAxisAlignment.end,
            actionGap: 2,
          ),
          globalTooltipActions: [
            TooltipActionButton(
              name: '上一个',
              type: TooltipDefaultActionType.previous,
              textStyle: TextStyle(color: Colors.white),
              hideActionWidgetForShowcase: [_showcaseKeys.first],
              backgroundColor: Colors.transparent,
            ),
            TooltipActionButton(
              name: '下一个',
              type: TooltipDefaultActionType.next,
              textStyle: TextStyle(color: Colors.white),
              hideActionWidgetForShowcase: [_showcaseKeys.last],
              backgroundColor: MTheme.primary2,
            ),
            TooltipActionButton(
                name: '完成',
                type: TooltipDefaultActionType.skip,
                textStyle: TextStyle(color: Colors.white),
                hideActionWidgetForShowcase:
                    _showcaseKeys.sublist(0, _showcaseKeys.length - 1),
                backgroundColor: MTheme.primary2,
                onTap: () {
                  CourseBox.put('isFirstTime', false);
                  ShowCaseWidget.of(_showcaseContext).dismiss();
                })
          ],
          builder: (showcaseContext) {
            if (_isFirstTime && !_hasStartedShowcase) {
              _refresh(() => _showcaseContext = showcaseContext);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refresh(() => _hasStartedShowcase = true);
                ShowCaseWidget.of(_showcaseContext)
                    .startShowCase(_showcaseKeys);
              });
            }
            return BasePage.gradient(
              headerPad: false,
              extraHeight: MTheme.radius,
              header: BaseHeader(
                title: buildShowcaseWidget(
                  key: GlobalKeys.showcaseCourseTableHeaderKey,
                  title: '课表选择',
                  description: '一键切换上/下学期、普通/选课课表以及共享课表。',
                  child: HeaderSelector<String>(
                    enabled: !_isLoading,
                    initialValue: _currentContainer.id,
                    onSelect: (value) {
                      final container =
                          containers.where((c) => c.id == value).firstOrNull;
                      if (container != null) {
                        _refresh(() => _currentContainer = container);
                      }
                    },
                    count: containers.length,
                    titleBuilder: (context, value) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            Text(
                              '课程表',
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            AutoSizeText(
                              _parseDisplayString(containers
                                      .where((c) => c.id == value)
                                      .firstOrNull
                                      ?.term ??
                                  ''),
                              maxLines: 1,
                              maxFontSize: 12,
                              minFontSize: 8,
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      );
                    },
                    tileValueBuilder: (context, index) => containers[index].id!,
                    tileTextBuilder: (context, index) {
                      final container = containers[index];
                      return Row(
                        children: [
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  container.term,
                                  style: TextStyle(fontSize: 14),
                                ),
                                if (container.sharerId != null)
                                  Text(
                                    '来自：${container.remark ?? container.sharerId ?? '未知'}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: FButton.icon(
                              onPress: () async {
                                if (container.sharerId == null) return;
                                bool? r = await showAdaptiveDialog(
                                  context: context,
                                  builder: (context) => FDialog(
                                    direction: Axis.horizontal,
                                    title: Text(
                                      '确定要删除${container.remark ?? container.sharerId}的共享课程表吗？',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    body: SizedBox(height: 12.0),
                                    actions: [
                                      FButton(
                                        style: FButtonStyle.outline,
                                        onPress: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        label: Text('取消'),
                                      ),
                                      FButton(
                                        onPress: () =>
                                            Navigator.of(context).pop(true),
                                        label: Text('确定'),
                                      ),
                                    ],
                                  ),
                                );

                                if (r == true) {
                                  await CourseBox.put('sharedContainers',
                                      ValueService.sharedContainers);

                                  final p = await SWUSTStoreApiService
                                      .removeSharedCourseTable(
                                          container.id ?? '', userId ?? '');

                                  if (p.status != Status.ok) {
                                    if (!context.mounted) return;
                                    showErrorToast(context, '删除失败：${p.value}');
                                    return;
                                  }

                                  _refresh(() => ValueService.sharedContainers
                                      .removeWhere(
                                          (c) => c.id == container.id));

                                  if (!context.mounted) return;
                                  showSuccessToast(context, '删除成功！');
                                }
                              },
                              style: FButtonStyle.ghost,
                              child: FaIcon(
                                FontAwesomeIcons.solidTrashCan,
                                color: container.sharerId != null
                                    ? Colors.red
                                    : Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    fallbackTitle: Text('未知学期', style: titleStyle),
                  ),
                ),
                suffixIcons: [
                  buildShowcaseWidget(
                    key: GlobalKeys.showcaseCourseTableSettingsKey,
                    title: '课程表设置',
                    description: '一键设置课程表共享等功能，之后可以自定义课表哦~',
                    child: IconButton(
                      onPressed: () {
                        pushTo(
                          context,
                          PopScope(
                            canPop: true,
                            onPopInvokedWithResult: (didPop, _) {
                              setState(() {});
                            },
                            child: const CourseTableSettingsPage(),
                          ),
                        );
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.gear,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  buildShowcaseWidget(
                    key: GlobalKeys.showcaseCourseTableRefreshKey,
                    title: '刷新课程表',
                    description: '课表出问题了？刷新一下试试！',
                    child: Stack(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (_isLoading) return;

                            _refresh(() {
                              _isLoading = true;
                              _refreshAnimationController.repeat();
                            });

                            try {
                              // 1. 检查是否有共享状态
                              final userId = GlobalService
                                  .soaService?.currentAccount?.account;
                              if (userId != null) {
                                final shareStatus = await SWUSTStoreApiService
                                    .getCourseShareStatus(userId);
                                if (shareStatus.status == Status.ok &&
                                    shareStatus.value == true) {
                                  // 如果开启了共享，上传课程表
                                  final uploadResult =
                                      await SWUSTStoreApiService
                                          .uploadCourseTable(
                                    userId,
                                    _containers,
                                  );
                                  if (uploadResult.status != Status.ok) {
                                    if (!context.mounted) return;
                                    showErrorToast(context,
                                        uploadResult.value ?? '未成功上传课表');
                                  }
                                }
                              }

                              // 2. 获取共享课表
                              final sharedList = <CoursesContainer>[];
                              for (final container
                                  in ValueService.sharedContainers) {
                                final containerId = container.id;
                                final shared = await SWUSTStoreApiService
                                    .getSharedCourseTable(
                                  containerId!,
                                  userId ?? '',
                                );
                                if (shared.status != Status.ok) continue;
                                final res = shared.value as CoursesContainer;
                                res.remark = container.remark;
                                debugPrint(
                                    '获取共享课表：${container.remark}, ${container.sharerId}, $containerId = $shared');
                                sharedList.add(res);
                              }

                              if (sharedList.isNotEmpty) {
                                await CourseBox.put(
                                    'sharedContainers', sharedList);
                                _refresh(() {
                                  ValueService.sharedContainers = sharedList;
                                });
                              }

                              // 3. 获取自己的课表
                              final res = await GlobalService.soaService!
                                  .getCourseTables();
                              if (res.status != Status.ok) return;

                              List<CoursesContainer> containers =
                                  (res.value as List<dynamic>).cast();
                              final current = (containers + sharedList)
                                  .where((c) => c.id == _currentContainer.id);
                              await CourseBox.put('courseTables', containers);

                              _refresh(() {
                                _containers = containers;
                                _currentContainer = current.isNotEmpty
                                    ? current.first
                                    : getCurrentCoursesContainer(
                                        widget.activities, containers);
                                ValueService.coursesContainers = _containers;
                                ValueService.currentCoursesContainer =
                                    _currentContainer;
                              });
                            } finally {
                              _refresh(() {
                                _isLoading = false;
                                _refreshAnimationController.stop();
                                _refreshAnimationController.reset();
                              });
                            }
                          },
                          icon: RotationTransition(
                            turns: _refreshAnimationController,
                            child: FaIcon(
                              FontAwesomeIcons.rotateRight,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        if (_isLoading)
                          Positioned(
                            bottom: 0,
                            left: 20 / 2,
                            child: Text(
                              '刷新中...',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: CourseTable(
                  container: _currentContainer,
                  isLoading: _isLoading,
                ),
              ),
            );
          }),
    );
  }
}
