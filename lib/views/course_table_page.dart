import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';

import '../components/course_table/course_table.dart';
import '../components/m_scaffold.dart';
import '../utils/router.dart';
import 'main_page.dart';

class CourseTablePage extends StatefulWidget {
  const CourseTablePage({super.key, required this.entries});

  final List<CourseEntry> entries;

  @override
  State<StatefulWidget> createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage> {
  @override
  Widget build(BuildContext context) {
    return MScaffold(
        child: FScaffold(
            contentPad: false,
            header: FHeader.nested(
              title: const Text(
                '课程表',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              prefixActions: [
                FHeaderAction(
                    icon: FIcon(FAssets.icons.chevronLeft),
                    onPress: () {
                      Navigator.of(context).pop();
                    })
              ],
            ),
            content: CourseTable(entries: widget.entries)));
  }
}
