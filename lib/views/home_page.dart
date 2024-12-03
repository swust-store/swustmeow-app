import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/components/double_column.dart';
import 'package:miaomiaoswust/components/m_scaffold.dart';
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
    return MScaffold(
        safeTop: true,
        PaddingContainer(
          decoration:
              BoxDecoration(color: context.theme.colorScheme.background),
          DoubleColumn(
            left: [
              Clickable(
                  FCard(
                    image: FIcon(FAssets.icons.bookText),
                    title: const Text('课程表'),
                    subtitle: const Text('看看今天有什么课吧~'),
                    style: FCardStyle(
                        decoration: context.theme.cardStyle.decoration.copyWith(
                            color: context.theme.colorScheme.primaryForeground),
                        contentStyle: context.theme.cardStyle.contentStyle),
                  ), onPress: () {
                pushTo(context, const CourseTablePage());
                setState(() {});
              })
            ],
            right: [],
          ),
        ));
  }
}
