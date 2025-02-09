import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/header_selector.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/utils/courses.dart';
import 'package:swustmeow/utils/status.dart';

import '../components/course_table/course_table.dart';
import '../components/utils/base_header.dart';
import '../components/utils/base_page.dart';
import '../entity/soa/course/courses_container.dart';
import '../services/global_service.dart';
import '../services/value_service.dart';

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

  @override
  void initState() {
    super.initState();
    _containers = widget.containers;
    _currentContainer = widget.currentContainer;
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
    final week = w > 0 ? '($w周)' : '';
    return '$s-$e-$t$week';
  }

  @override
  Widget build(BuildContext context) {
    final terms = _containers.map((c) => c.term).toList();
    final titleStyle = TextStyle(fontSize: 14, color: Colors.white);

    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.color(
        headerPad: false,
        header: BaseHeader(
          title: HeaderSelector<String>(
            enabled: !_isLoading,
            initialValue: _currentContainer.term,
            onSelect: (value) {
              final container = _containers.singleWhere((c) => c.term == value);
              _refresh(() => _currentContainer = container);
            },
            count: terms.length,
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
                      _parseDisplayString(value),
                      maxLines: 1,
                      maxFontSize: 12,
                      minFontSize: 8,
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              );
            },
            tileValueBuilder: (context, index) => terms[index],
            tileTextBuilder: (context, index) => terms[index],
            fallbackTitle: Text('未知学期', style: titleStyle),
          ),
          suffixIcons: [
            IconButton(
              onPressed: () async {
                if (_isLoading) return;

                _refresh(() => _isLoading = true);
                final res = await GlobalService.soaService!.getCourseTables();
                if (res.status != Status.ok) return;
                List<CoursesContainer> containers =
                    (res.value as List<dynamic>).cast();
                final current =
                    containers.where((c) => c.term == _currentContainer.term);
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
        content: Padding(
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
