import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/components/double_column.dart';
import 'package:miaomiaoswust/components/m_scaffold.dart';
import 'package:miaomiaoswust/components/padding_container.dart';
import 'package:miaomiaoswust/core/festival/festivals.dart';
import 'package:miaomiaoswust/core/values.dart';
import 'package:miaomiaoswust/utils/list.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/utils/widget.dart';
import 'package:miaomiaoswust/views/course_table_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  String? currentGreeting;
  DateTime cur = DateTime.now();

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
    return MScaffold(
        safeTop: true,
        PaddingContainer(
            decoration:
                BoxDecoration(color: context.theme.colorScheme.background),
            Column(
              children: [
                _getGreeting(),
                DoubleColumn(
                  left: joinPlaceholder(gap: 10, widgets: [
                    Clickable(
                        FCard(
                          image: FIcon(FAssets.icons.bookText),
                          title: const Text('课程表'),
                          subtitle: const Text('看看今天有什么课吧~'),
                          style: FCardStyle(
                              decoration: context.theme.cardStyle.decoration
                                  .copyWith(
                                      color: context
                                          .theme.colorScheme.primaryForeground),
                              contentStyle:
                                  context.theme.cardStyle.contentStyle),
                        ), onPress: () {
                      pushTo(context, const CourseTablePage());
                      setState(() {});
                    })
                  ]),
                  right: const [],
                )
              ],
            )));
  }

  bool generateHolidayGreeting(DateTime cur) {
    var holiday =
        festivals.where((holiday) => holiday.isInHoliday(cur)).toList();
    if (holiday.isEmpty) return false;
    setState(() => currentGreeting = holiday.first.greetings.randomElement);
    return true;
  }

  void generateTimeGreeting() {
    var texts = Values.timeGreetings.singleWhere((entry) {
      final lr = (entry['time'] as String).split('-');
      return isHourMinuteInRange(null, lr.first, lr.last, ':');
    })['greetings'] as List<String>;
    setState(() => currentGreeting = texts.randomElement);
  }

  Widget _getGreeting() {
    if (currentGreeting == null ||
        _lastLifecycleState == AppLifecycleState.resumed) {
      final holiday = generateHolidayGreeting(cur);
      if (!holiday) generateTimeGreeting();
    }

    // 用来修复 `emoji` 导致的文字下垂
    const strutStyle = StrutStyle(forceStrutHeight: true, height: 3.2);
    const style = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);

    currentGreeting = '愿你有个宁静的夜晚💫';
    final result = currentGreeting ?? 'Hello~';

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
