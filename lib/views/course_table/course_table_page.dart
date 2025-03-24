import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'package:swustmeow/components/header_selector.dart';
import 'package:swustmeow/components/utils/empty.dart';
import 'package:swustmeow/components/utils/refresh_icon.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/services/boxes/course_box.dart';
import 'package:swustmeow/utils/courses.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';

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
  late String? userId;
  late List<CoursesContainer> containers;

  @override
  void initState() {
    super.initState();
    _containers = widget.containers;
    _currentContainer = widget.currentContainer;
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    userId = GlobalService.soaService?.currentAccount?.account;
    containers = _containers +
        ValueService.sharedContainers
            .where((c) => c.sharerId != userId)
            .toList();
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

  @override
  Widget build(BuildContext context) {
    final imagePath = MTheme.courseTableImagePath;
    final enableBackgroundBlur =
        CourseBox.get('enableBackgroundBlur') as bool? ?? false;
    final backgroundBlurSigma =
        CourseBox.get('backgroundBlurSigma') as double? ?? 5.0;

    return BasePage(
      headerPad: false,
      extraHeight: MTheme.radius,
      backgroundImage: imagePath != null
          ? DecorationImage(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            )
          : null,
      blurBackground: imagePath != null && enableBackgroundBlur,
      blurSigma: backgroundBlurSigma,
      header: _buildHeader(),
      content: Padding(
        padding: EdgeInsets.only(top: 4.0),
        child: CourseTable(
          container: _currentContainer,
          isLoading: _isLoading,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final color = MTheme.backgroundText;
    final titleStyle = TextStyle(fontSize: 14, color: Colors.white);

    return BaseHeader(
      color: color,
      showBackButton: false,
      title: HeaderSelector<String>(
        enabled: !_isLoading,
        initialValue: _currentContainer.id,
        color: color,
        onSelect: (value) {
          final container = containers.where((c) => c.id == value).firstOrNull;
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
                    color: color,
                  ),
                ),
                AutoSizeText(
                  containers
                          .where((c) => c.id == value)
                          .firstOrNull
                          ?.parseDisplayString() ??
                      '',
                  maxLines: 1,
                  maxFontSize: 12,
                  minFontSize: 8,
                  style: TextStyle(color: color),
                ),
              ],
            ),
          );
        },
        tileValueBuilder: (context, index) => containers[index].id!,
        tileTextBuilder: (context, index) {
          final container = containers[index];
          return Row(
            children: [
              SizedBox(width: 28),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      container.term,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      container.sharerId != null
                          ? '来自：${container.remark ?? container.sharerId ?? '未知'}'
                          : '我的课表',
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
                child: container.sharerId != null
                    ? FButton.icon(
                        onPress: () async {
                          if (container.sharerId == null) return;
                          await _deleteSharedContainer(container);
                        },
                        style: FButtonStyle.ghost,
                        child: FaIcon(
                          FontAwesomeIcons.solidTrashCan,
                          color: Colors.red,
                          size: 16,
                        ),
                      )
                    : const Empty(),
              ),
            ],
          );
        },
        fallbackTitle: Text('未知学期', style: titleStyle),
      ),
      suffixIcons: [
        IconButton(
          onPressed: () {
            pushTo(
              context,
              '/course_table/settings',
              PopScope(
                canPop: true,
                onPopInvokedWithResult: (didPop, _) {
                  setState(() {});
                },
                child: CourseTableSettingsPage(
                  onRefresh: () => setState(() {}),
                ),
              ),
            );
          },
          icon: FaIcon(
            FontAwesomeIcons.gear,
            color: color,
            size: 20,
          ),
        ),
        RefreshIcon(
          color: color,
          isRefreshing: _isLoading,
          onRefresh: () async {
            if (_isLoading) return;
            await _refreshCourseTable();
          },
        ),
      ],
    );
  }

  Future<void> _deleteSharedContainer(CoursesContainer container) async {
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
            onPress: () => Navigator.of(context).pop(true),
            label: Text('确定'),
          ),
        ],
      ),
    );

    if (r == true) {
      await CourseBox.put('sharedContainers', ValueService.sharedContainers);

      final p = await SWUSTStoreApiService.removeSharedCourseTable(
          container.id ?? '', userId ?? '');

      if (p.status != Status.ok) {
        showErrorToast('删除失败：${p.value}');
        return;
      }

      _refresh(() => ValueService.sharedContainers
          .removeWhere((c) => c.id == container.id));

      showSuccessToast('删除成功！');
    }
  }

  Future<void> _refreshCourseTable() async {
    _refresh(() {
      _isLoading = true;
      _refreshAnimationController.repeat();
    });

    try {
      // 1. 检查是否有共享状态
      final userId = GlobalService.soaService?.currentAccount?.account;
      if (userId != null) {
        final shareStatus =
            await SWUSTStoreApiService.getCourseShareStatus(userId);
        if (shareStatus.status == Status.ok && shareStatus.value == true) {
          // 如果开启了共享，上传课程表
          final uploadResult = await SWUSTStoreApiService.uploadCourseTable(
            userId,
            _containers,
          );
          if (uploadResult.status != Status.ok) {
            showErrorToast(uploadResult.value ?? '未成功上传课表');
          }
        }
      }

      // 2. 获取共享课表
      final sharedList = <CoursesContainer>[];
      for (final container in ValueService.sharedContainers) {
        final containerId = container.id;
        final shared = await SWUSTStoreApiService.getSharedCourseTable(
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
        await CourseBox.put('sharedContainers', sharedList);
        _refresh(() {
          ValueService.sharedContainers = sharedList;
        });
      }

      // 3. 获取自己的课表
      final res = await GlobalService.soaService!.getCourseTables();
      if (res.status != Status.ok) return;

      List<CoursesContainer> containers = (res.value as List<dynamic>).cast();
      final current =
          (containers + sharedList).where((c) => c.id == _currentContainer.id);
      await CourseBox.put('courseTables', containers);

      _refresh(() {
        _containers = containers;
        _currentContainer = current.isNotEmpty
            ? current.first
            : getCurrentCoursesContainer(widget.activities, containers);
        ValueService.coursesContainers = _containers;
        ValueService.currentCoursesContainer = _currentContainer;
      });
    } finally {
      GlobalService.refreshHomeCourseWidgets();
      _refresh(() {
        _isLoading = false;
        _refreshAnimationController.stop();
        _refreshAnimationController.reset();
      });
    }
  }
}
