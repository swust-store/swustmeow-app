import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/empty.dart';
import 'package:miaomiaoswust/entity/activity/activity.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:miaomiaoswust/views/cards/calendar_card.dart';
import 'package:miaomiaoswust/views/cards/course_table_card.dart';

import '../components/clickable.dart';
import '../components/double_column.dart';
import '../components/m_scaffold.dart';
import '../components/padding_container.dart';
import '../data/activities_store.dart';
import '../data/greetings.dart';
import '../data/values.dart';
import '../utils/list.dart';
import '../utils/router.dart';
import '../utils/time.dart';
import '../utils/widget.dart';
import 'calendar_page.dart';
import 'course_table_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const fallbackGreeting = 'Hello~';
  String? _currentGreeting;
  Timer? _timer;
  List<Activity> _activities = defaultActivities;

  Widget _courseTableChild = const Empty();
  Widget _calendarChild = const Empty();

  @override
  void initState() {
    super.initState();
    _timer = _timer ??
        Timer.periodic(
            const Duration(minutes: 1), (_) => _updateGreeting(DateTime.now()));
    _fetchActivities();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        decoration: context.theme.cardStyle.decoration
            .copyWith(color: context.theme.colorScheme.primaryForeground),
        contentStyle: context.theme.cardStyle.contentStyle);

    final cards = [
      CourseTableCard(cardStyle: cardStyle),
      CalendarCard(cardStyle: cardStyle, activities: _activities)
    ];

    return MScaffold(
        safeTop: true,
        child: PaddingContainer(
            decoration:
                BoxDecoration(color: context.theme.colorScheme.background),
            child: Column(
              children: [
                _getGreeting(DateTime.now()),
                DoubleColumn(
                    left: joinPlaceholder(
                        gap: 10,
                        widgets: cards
                            .where((element) => cards.indexOf(element) % 2 == 0)
                            .toList()),
                    right: joinPlaceholder(
                        gap: 10,
                        widgets: cards
                            .where((element) => cards.indexOf(element) % 2 == 1)
                            .toList())),
              ],
            )));
  }

  bool _generateActivityGreeting() {
    var activity =
        _activities.where((ac) => ac.isInActivity(Values.now)).toList();
    if (activity.isEmpty) return false;
    if (activity.first.greetings == null) return false;
    setState(() => _currentGreeting = activity.first.greetings!.randomElement);
    return true;
  }

  void _generateTimeGreeting(DateTime currentTime) {
    final w = timeGreetings.where((entry) {
      final lr = (entry['time'] as String).split('-');
      return isHourMinuteInRange(currentTime.hmString, lr.first, lr.last, ':');
    });
    final result = w.isEmpty
        ? fallbackGreeting
        : (w.first['greetings'] as List<String>).randomElement;
    setState(() => _currentGreeting = result);
  }

  void _updateGreeting(DateTime currentTime) {
    final activity = _generateActivityGreeting();
    if (!activity) _generateTimeGreeting(DateTime.now());
  }

  Widget _getGreeting(DateTime currentTime) {
    if (_currentGreeting == null) {
      _updateGreeting(currentTime);
    }

    // 用来修复 `emoji` 导致的文字下垂
    const strutStyle = StrutStyle(forceStrutHeight: true, height: 3.2);
    const style = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);

    final result = _currentGreeting ?? fallbackGreeting;

    return SizedBox(
        height: 60,
        child: Align(
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              Text(
                result,
                style: style.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = Colors.black54),
                strutStyle: strutStyle,
              ),
              Text(
                result,
                style: style,
                strutStyle: strutStyle,
              )
            ],
          ),
        ));
  }
}
