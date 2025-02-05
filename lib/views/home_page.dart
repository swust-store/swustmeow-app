import 'package:flutter/material.dart';
import 'package:swustmeow/components/cards/duifene_card.dart';
import 'package:swustmeow/components/greeting.dart';
import 'package:swustmeow/components/padding_container.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/global_service.dart';

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
            left: joinGap(
                gap: cardGap,
                axis: Axis.vertical,
                widgets: cards1
                    .where((element) => cards1.indexOf(element) % 2 == 0)
                    .toList()),
            right: joinGap(
                gap: 10,
                axis: Axis.vertical,
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
            left: joinGap(
                gap: cardGap,
                axis: Axis.vertical,
                widgets: cards2
                    .where((element) => cards2.indexOf(element) % 2 == 0)
                    .toList()),
            right: joinGap(
                gap: 10,
                axis: Axis.vertical,
                widgets: cards2
                    .where((element) => cards2.indexOf(element) % 2 == 1)
                    .toList())),
      ],
    )).withBackground;
  }
}
