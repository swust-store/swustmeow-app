import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/components/course_table/course_card.dart';
import 'package:miaomiaoswust/components/course_table/course_detail_card.dart';
import 'package:miaomiaoswust/components/course_table/header_row.dart';
import 'package:miaomiaoswust/components/course_table/time_column.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';
import 'package:miaomiaoswust/services/box_service.dart';

import '../../data/values.dart';
import '../../utils/color.dart';

class CourseTable extends StatefulWidget {
  const CourseTable({super.key, required this.entries});

  final List<CourseEntry> entries;

  @override
  State<StatefulWidget> createState() => _CourseTableState();
}

class _CourseTableState extends State<CourseTable> {
  @override
  void initState() {
    super.initState();
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
          generateColorFromString(entry.courseName, minBrightness: 0.5).value;
      entry.color = color;
      map[entry.courseName] = color;
    }
    await BoxService.courseEntryListBox
        .put('courseTableEntries', updatedEntries);
  }

  Widget _buildRow(int rowIndex) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimeColumn(
              number: rowIndex + 1, time: Values.courseTableTimes[rowIndex]),
          ...List.generate(7, (dayIndex) {
            final matched = widget.entries
                .where((entry) =>
                    entry.weekday == dayIndex + 1 &&
                    entry.numberOfDay == rowIndex + 1)
                .toList()
              ..sort((a, b) => a.endWeek.compareTo(b.endWeek));
            final actives =
                matched.where((e) => !e.checkIfFinished(matched)).toList();
            final display =
                actives.isNotEmpty ? actives.first : matched.lastOrNull;

            return Expanded(
                child: Clickable(
                    onPress: () {
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
                    child: CourseCard(
                      entry: display,
                      active: actives.isNotEmpty,
                    )));
          })
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const HeaderRow(),
            ...List.generate(6, (index) => Expanded(child: _buildRow(index)))
          ],
        ));
  }
}
