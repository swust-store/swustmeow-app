import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/entity/course/courses_container.dart';
import 'package:swustmeow/utils/courses.dart';
import 'package:swustmeow/utils/status.dart';

import '../components/course_table/course_table.dart';
import '../components/utils/base_page.dart';
import '../services/global_service.dart';
import '../services/value_service.dart';

class CourseTablePage extends StatefulWidget {
  const CourseTablePage(
      {super.key,
      required this.containers,
      required this.currentContainer,
      required this.activities});

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
  String? _currentValue;
  late FPopoverController _popoverController;
  late FRadioSelectGroupController<String> _groupController;
  bool _isPopoverOpened = false;

  @override
  void initState() {
    super.initState();
    _containers = widget.containers;
    _currentContainer = widget.currentContainer;
    _currentValue = _currentContainer.term;
    _popoverController = FPopoverController(vsync: this);
    _popoverController.addListener(() {
      _refresh(() => _isPopoverOpened = !_isPopoverOpened);
    });
    _groupController = FRadioSelectGroupController(value: _currentValue);
    _groupController.addListener(() {
      final value =
          _groupController.value.firstOrNull ?? _currentContainer.term;
      _refresh(() {
        final container = _containers.singleWhere((c) => c.term == value);
        _currentValue = value;
        _currentContainer = container;
      });
      _popoverController.hide();
    });
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  String _parseDisplayString(String term) {
    final [s, e, t] = term.split('-');
    final now = DateTime.now();
    final (_, _, w) =
        GlobalService.termDates.value[term]?.value ?? (now, now, -1);
    final [ts, te] = [s, e].map((x) => int.parse(x) - 2000).toList();
    final week = w > 0 ? '($w周)' : '';
    return '$ts-$te-$t$week';
  }

  @override
  Widget build(BuildContext context) {
    final terms = _containers.map((c) => c.term).toList();
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        top: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '课程表',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: FSelectMenuTile.builder(
                    title: AutoSizeText(
                      _currentValue ?? '未知学期',
                      style: TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    groupController: _groupController,
                    divider: FTileDivider.full,
                    count: terms.length,
                    enabled: !_isLoading,
                    autoHide: true,
                    suffixIcon: FIcon(
                      FAssets.icons.chevronsUpDown,
                      color: Colors.white,
                    ),
                    menuAnchor: Alignment.topCenter,
                    tileAnchor: Alignment.bottomCenter,
                    menuTileBuilder: (context, index) {
                      final value = terms[index];
                      return FSelectTile(
                        title: Transform.translate(
                          offset: Offset(-16.0, 0.0),
                          child: Center(
                            child: Text(_parseDisplayString(value),
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        value: value,
                        style: context.theme.selectMenuTileStyle.tileStyle,
                      );
                    },
                    style: context.theme.selectMenuTileStyle.copyWith(
                      tileStyle:
                          context.theme.selectMenuTileStyle.tileStyle.copyWith(
                        enabledBackgroundColor: Colors.transparent,
                        enabledHoveredBackgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        border:
                            Border.all(color: Colors.transparent, width: 0.0),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    if (_isLoading) return;

                    _refresh(() => _isLoading = true);
                    final res =
                        await GlobalService.soaService!.getCourseTables();
                    if (res.status != Status.ok) return;
                    List<CoursesContainer> containers =
                        (res.value as List<dynamic>).cast();
                    final current = containers
                        .where((c) => c.term == _currentContainer.term);
                    _refresh(() {
                      _containers = containers;
                      _currentContainer = current.isNotEmpty
                          ? current.first
                          : getCurrentCoursesContainer(
                              widget.activities, containers);
                      _isLoading = false;
                    });
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.rotateRight,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: CourseTable(
            container: _currentContainer,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
