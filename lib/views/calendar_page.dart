import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../components/calendar/calendar.dart';
import '../utils/router.dart';
import 'main_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
        contentPad: false,
        header: FHeader.nested(
          title: const Text(
            '日历',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          prefixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.chevronLeft),
                onPress: () => pushTo(context, const MainPage()))
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          child: Calendar(),
        ));
  }
}
