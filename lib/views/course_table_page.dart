import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/course_table/header_course_selector.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/entity/course/courses_container.dart';
import 'package:miaomiaoswust/utils/courses.dart';
import 'package:miaomiaoswust/utils/status.dart';

import '../components/course_table/course_table.dart';
import '../components/m_scaffold.dart';
import '../data/values.dart';
import '../services/global_service.dart';

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

class _CourseTablePageState extends State<CourseTablePage> {
  late List<CoursesContainer> _containers;
  late CoursesContainer _currentContainer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _containers = widget.containers;
    _currentContainer = widget.currentContainer;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
        flipX: Values.isFlipEnabled.value,
        flipY: Values.isFlipEnabled.value,
        child: MScaffold(
            child: FScaffold(
                contentPad: false,
                header: FHeader.nested(
                  title: HeaderCourseSelector(
                    defaultValue: _currentContainer.term,
                    values: _containers.map((c) => c.term).toList(),
                    onChange: (value) {
                      final container =
                          _containers.singleWhere((c) => c.term == value);
                      setState(() => _currentContainer = container);
                    },
                  ),
                  prefixActions: [
                    FHeaderAction(
                        icon: FIcon(FAssets.icons.chevronLeft),
                        onPress: () {
                          Navigator.of(context).pop();
                        })
                  ],
                  suffixActions: [
                    FHeaderAction(
                        icon: FIcon(FAssets.icons.rotateCcw),
                        onPress: () async {
                          setState(() => _isLoading = true);
                          final res =
                              await GlobalService.soaService!.getCourseTables();
                          if (res.status != Status.ok) return;
                          List<CoursesContainer> containers =
                              (res.value as List<dynamic>).cast();
                          final current = getCurrentCoursesContainer(
                              widget.activities, _containers);
                          setState(() {
                            _containers = containers;
                            _currentContainer = current;
                            _isLoading = false;
                          });
                        })
                  ],
                ),
                content: CourseTable(
                  container: _currentContainer,
                  isLoading: _isLoading,
                ))));
  }
}
