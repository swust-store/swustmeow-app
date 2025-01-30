import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/course_table/header_course_selector.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/entity/course/courses_container.dart';
import 'package:miaomiaoswust/utils/courses.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:miaomiaoswust/utils/widget.dart';

import '../components/course_table/course_table.dart';
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
        child: FScaffold(
            contentPad: false,
            header: FHeader.nested(
              title: HeaderCourseSelector(
                enabled: !_isLoading,
                currentTerm: _currentContainer.term,
                terms: _containers.map((c) => c.term).toList(),
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
                    icon: SizedBox(
                      width: 30,
                      child: FIcon(
                        FAssets.icons.rotateCw,
                        color: _isLoading
                            ? Colors.grey
                            : context.theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    onPress: () async {
                      if (_isLoading) return;

                      setState(() => _isLoading = true);
                      final res =
                          await GlobalService.soaService!.getCourseTables();
                      if (res.status != Status.ok) return;
                      List<CoursesContainer> containers =
                          (res.value as List<dynamic>).cast();
                      final current = containers
                          .where((c) => c.term == _currentContainer.term);
                      setState(() {
                        _containers = containers;
                        _currentContainer = current.isNotEmpty
                            ? current.first
                            : getCurrentCoursesContainer(
                                widget.activities, containers);
                        _isLoading = false;
                      });
                    })
              ],
            ).withBackground,
            content: CourseTable(
              container: _currentContainer,
              isLoading: _isLoading,
            ).withBackground));
  }
}
