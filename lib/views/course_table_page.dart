import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/course_table.dart';
import 'package:miaomiaoswust/components/m_scaffold.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/entity/course_table_entry_entity.dart';

class CourseTablePage extends StatefulWidget {
  const CourseTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage> {
  @override
  Widget build(BuildContext context) {
    final entries = <CourseTableEntryEntity>[];
    return MScaffold(Column(
      children: [
        PaddingContainer(
          FHeader.nested(
            title: const Text(
              '课程表',
              style: TextStyle(fontSize: 14),
            ),
            prefixActions: [
              FIcon(
                FAssets.icons.arrowLeft,
                size: 22,
              )
            ],
            style: FNestedHeaderStyle(
                titleTextStyle: const TextStyle(fontSize: 14),
                actionStyle: context.theme.headerStyle.nestedStyle.actionStyle,
                padding: EdgeInsets.zero),
          ),
        ),
        Expanded(
            child: CourseTable(
          entries: entries,
        ))
        // const Expanded(child: CourseSchedule())
      ],
    ));
  }
}
