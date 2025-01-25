import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/cards/duifene_card.dart';
import 'package:miaomiaoswust/components/greeting.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/services/global_service.dart';

import '../components/cards/calendar_card.dart';
import '../components/cards/course_table_card.dart';
import '../components/cards/time_card.dart';
import '../components/cards/todo_card.dart';
import '../components/double_column.dart';
import '../components/m_scaffold.dart';
import '../components/padding_container.dart';
import '../data/activities_store.dart';
import '../utils/widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Activity> _activities;
  static const cardGap = 10.0;
  double height = 200;

  @override
  void initState() {
    super.initState();
    _activities = defaultActivities + GlobalService.extraActivities.value;
  }

  @override
  Widget build(BuildContext context) {
    final cardStyle = FCardStyle(
        decoration: context.theme.cardStyle.decoration.copyWith(
            color: context.theme.colorScheme.primaryForeground,
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        contentStyle: context.theme.cardStyle.contentStyle);

    final cards1 = [
      CourseTableCard(cardStyle: cardStyle),
      CalendarCard(cardStyle: cardStyle, activities: _activities)
    ];

    final cards2 = [DuiFenECard(cardStyle: cardStyle)];

    return MScaffold(
      safeTop: true,
      safeBottom: false,
      child: PaddingContainer(
          child: Column(
        children: [
          Greeting(activities: _activities),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TimeCard(cardStyle: cardStyle),
          ),
          const SizedBox(height: cardGap),
          DoubleColumn(
              left: joinPlaceholder(
                  gap: cardGap,
                  widgets: cards1
                      .where((element) => cards1.indexOf(element) % 2 == 0)
                      .toList()),
              right: joinPlaceholder(
                  gap: 10,
                  widgets: cards1
                      .where((element) => cards1.indexOf(element) % 2 == 1)
                      .toList())),
          const SizedBox(height: cardGap),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 144,
            child: TodoCard(cardStyle: cardStyle),
          ),
          const SizedBox(height: cardGap),
          DoubleColumn(
              left: joinPlaceholder(
                  gap: cardGap,
                  widgets: cards2
                      .where((element) => cards2.indexOf(element) % 2 == 0)
                      .toList()),
              right: joinPlaceholder(
                  gap: 10,
                  widgets: cards2
                      .where((element) => cards2.indexOf(element) % 2 == 1)
                      .toList())),
        ],
      )),
    );
  }
}
