import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/components/course_table/course_card.dart';
import 'package:miaomiaoswust/components/course_table/course_detail_card.dart';
import 'package:miaomiaoswust/components/course_table/header_row.dart';
import 'package:miaomiaoswust/components/course_table/time_column.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/utils/time.dart';

import '../../data/values.dart';
import '../../utils/color.dart';

class CourseTable extends StatefulWidget {
  const CourseTable({super.key, required this.entries});

  final List<CourseEntry> entries;

  @override
  State<StatefulWidget> createState() => _CourseTableState();
}

class _CourseTableState extends State<CourseTable> {
  late final PageController _pageController;
  late int _initialPage;

  @override
  void initState() {
    super.initState();
    final (_, w) = getCourseWeekNum(DateTime.now());
    _initialPage = (w > 19 ? 19 : w) - 1;
    _pageController =
        PageController(initialPage: _initialPage, keepPage: false);
    _generateRandomColors();
  }

  Future<void> _generateRandomColors() async {
    final Map<String, int> map = {};
    final List<CourseEntry> updatedEntries = widget.entries;
    for (final entry in updatedEntries) {
      if (entry.color != 0xFF000000) continue;

      if (map.keys.contains(entry.courseName)) {
        entry.color = map[entry.courseName]!;
        continue;
      }
      int color =
          generateColorFromString(entry.courseName, minBrightness: 0.5).toInt();
      entry.color = color;
      map[entry.courseName] = color;
    }
    await BoxService.courseBox.put('courseTableEntries', updatedEntries);
  }

  Widget _buildTimeColumn() {
    return Column(
        children: List.generate(
            6,
            (index) => Expanded(
                child: TimeColumn(
                    number: index + 1, time: Values.courseTableTimes[index]))));
  }

  Widget _buildColumn(int columnIndex, int pageIndex) {
    final w = pageIndex + 1;
    return Column(
      children: [
        ...List.generate(6, (indexOfDay) {
          final matched = widget.entries
              .where((entry) =>
                  entry.numberOfDay == indexOfDay + 1 &&
                  entry.weekday == columnIndex + 1)
              .toList()
            ..sort((a, b) => a.endWeek.compareTo(b.endWeek));
          final actives =
              matched.where((e) => w >= e.startWeek && w <= e.endWeek).toList();
          final display =
              actives.isNotEmpty ? actives.first : matched.lastOrNull;

          return Expanded(
              child: Clickable(
                  onClick: () {
                    if (display != null) {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CourseDetailCard(
                                entries: matched,
                                clicked: display,
                              ));
                    }
                  },
                  child:
                      CourseCard(entry: display, active: actives.isNotEmpty)));
        })
      ],
    );
  }

  Widget _buildPage(int pageIndex) {
    return Row(children: [
      _buildTimeColumn(),
      ...List.generate(
          7, (index) => Expanded(child: _buildColumn(index, pageIndex)))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(children: [
          ListenableBuilder(
              listenable: _pageController,
              builder: (context, _) {
                final page = _pageController.positions.isEmpty ||
                        _pageController.page == null
                    ? _initialPage
                    : _pageController.page ?? _initialPage;
                final result = (page - page.toInt()).abs() >= 0.5
                    ? page.ceil()
                    : page.floor();
                return HeaderRow(weekNum: result + 1);
              }),
          Expanded(
              flex: 1,
              child: PageView.builder(
                  controller: _pageController,
                  itemCount: 19,
                  itemBuilder: (context, pageIndex) => _buildPage(pageIndex)))
        ]));
  }
}
