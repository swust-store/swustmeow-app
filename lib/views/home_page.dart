import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/cards/duifene_card.dart';
import 'package:miaomiaoswust/components/greeting.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/services/global_service.dart';

import '../components/cards/calendar_card.dart';
import '../components/cards/course_table_card.dart';
import '../components/cards/time_card.dart';
import '../components/cards/todo_card.dart';
import '../components/double_column.dart';
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
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final box = BoxService.activitiesBox;
    List<Activity>? extra =
        (box.get('extraActivities') as List<dynamic>?)?.cast();
    if (extra == null) return;
    setState(() => _activities = defaultActivities + extra);
  }

  @override
  Widget build(BuildContext context) {
    final cards1 = [
      CourseTableCard(activities: _activities),
      CalendarCard(activities: _activities)
    ];

    final cards2 = [const DuiFenECard()];

    return PaddingContainer(
        child: ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        Greeting(activities: _activities),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TimeCard(),
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
          child: const TodoCard(),
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
    )).withBackground;
  }
}
