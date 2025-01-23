import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/greeting.dart';
import 'package:miaomiaoswust/entity/activity/activity.dart';
import 'package:miaomiaoswust/utils/status.dart';

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
  List<Activity> _activities = defaultActivities;
  static const cardGap = 10.0;
  double height = 200;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    final extraResult = await getExtraActivities();
    if (extraResult.status == Status.ok) {
      setState(() => _activities = defaultActivities + extraResult.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardStyle = FCardStyle(
        decoration: context.theme.cardStyle.decoration.copyWith(
            color: context.theme.colorScheme.primaryForeground,
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        contentStyle: context.theme.cardStyle.contentStyle);

    final cards = [
      CourseTableCard(cardStyle: cardStyle),
      CalendarCard(cardStyle: cardStyle, activities: _activities)
    ];

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
          const SizedBox(
            height: cardGap,
          ),
          DoubleColumn(
              left: joinPlaceholder(
                  gap: cardGap,
                  widgets: cards
                      .where((element) => cards.indexOf(element) % 2 == 0)
                      .toList()),
              right: joinPlaceholder(
                  gap: 10,
                  widgets: cards
                      .where((element) => cards.indexOf(element) % 2 == 1)
                      .toList())),
          const SizedBox(
            height: cardGap,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 180,
            child: TodoCard(cardStyle: cardStyle),
          ),
        ],
      )),
    );
  }
}
