import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/components/double_column.dart';
import 'package:miaomiaoswust/components/m_scaffold.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/core/values.dart';
import 'package:miaomiaoswust/utils/list.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:miaomiaoswust/views/calendar_page.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';

import '../core/activity/store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  String? currentGreeting;
  static const fallbackGreeting = 'Hello~';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lastLifecycleState = state);
  }

  @override
  Widget build(BuildContext context) {
    jumpPage(Widget widget) {
      pushTo(context, widget);
      setState(() {});
    }

    final cardStyle = FCardStyle(
        decoration: context.theme.cardStyle.decoration
            .copyWith(color: context.theme.colorScheme.primaryForeground),
        contentStyle: context.theme.cardStyle.contentStyle);

    final List<Map<String, dynamic>> cardsData = [
      {
        'icon': FAssets.icons.bookText,
        'title': '课程表',
        'subtitle': '看看今天有什么课吧~',
        'page': const CourseTablePage()
      },
      {
        'icon': FAssets.icons.calendar,
        'title': '日历',
        'subtitle': '看看什么时候放假呢~',
        'page': const CalendarPage()
      }
    ];

    final cards = cardsData
        .map((data) => Clickable(
            FCard(
                image: FIcon(data['icon'] as SvgAsset),
                title: Text(data['title'] as String),
                subtitle: Text(data['subtitle'] as String),
                style: cardStyle),
            onPress: () => jumpPage(data['page'] as Widget)))
        .toList();

    return MScaffold(
        safeTop: true,
        PaddingContainer(
            decoration:
                BoxDecoration(color: context.theme.colorScheme.background),
            Column(
              children: [
                _getGreeting(),
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

  bool generateActivityGreeting() {
    var activity =
        activities.where((ac) => ac.isInActivity(Values.now)).toList();
    if (activity.isEmpty) return false;
    if (activity.first.greetings == null) return false;
    setState(() => currentGreeting = activity.first.greetings!.randomElement);
    return true;
  }

  void generateTimeGreeting() {
    final w = Values.timeGreetings.where((entry) {
      final lr = (entry['time'] as String).split('-');
      return isHourMinuteInRange(null, lr.first, lr.last, ':');
    });
    final result = w.isEmpty
        ? fallbackGreeting
        : (w.first['greetings'] as List<String>).randomElement;
    setState(() => currentGreeting = result);
  }

  Widget _getGreeting() {
    if (currentGreeting == null ||
        _lastLifecycleState == AppLifecycleState.resumed) {
      final activity = generateActivityGreeting();
      if (!activity) generateTimeGreeting();
    }

    // 用来修复 `emoji` 导致的文字下垂
    const strutStyle = StrutStyle(forceStrutHeight: true, height: 3.2);
    const style = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);

    final result = currentGreeting ?? fallbackGreeting;

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
