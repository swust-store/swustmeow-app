import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/components/double_column.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PaddingContainer(
      DoubleColumn(
        left: [
          Clickable(
              FCard(
                title: const Text('课程表'),
                subtitle: const Text('看看今天有什么课吧~'),
              ), onPress: () {
            pushTo(context, const CourseTablePage());
            setState(() {});
          })
        ],
        right: [],
      ),
    );
  }
}
