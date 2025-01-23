import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/entity/activity/activity.dart';
import 'package:miaomiaoswust/entity/activity/activity_type.dart';
import 'package:miaomiaoswust/utils/router.dart';
import 'package:miaomiaoswust/views/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../entity/calendar_event.dart';
import '../../../entity/system_calendar.dart';
import '../../../services/box_service.dart';
import '../../../utils/calendar.dart';
import '../../../utils/status.dart';

class CalendarCard extends StatefulWidget {
  const CalendarCard(
      {super.key, required this.cardStyle, required this.activities});

  final FCardStyle cardStyle;
  final List<Activity> activities;

  @override
  State<StatefulWidget> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  List<SystemCalendar>? _systemCalendars;
  List<CalendarEvent>? _events;
  List<CalendarEvent>? _systemEvents;
  bool _eventsRefreshLock = false;

  List<String>? _todayEvents;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllSystemCalendars();
  }

  void _getTodayEvents() {
    final now = DateTime.now();

    final activities = widget.activities
        .where((ac) => ac.isInActivity(now))
        .where((ac) =>
            ac.display && ac.name != null && ac.type != ActivityType.today)
        .toList()
      ..sort((a, b) => b.type.priority.compareTo(a.type.priority)); // 降序排序

    final eventsMatched = getEventsMatched(_events, now);
    final systemEventsMatched = getEventsMatched(_systemEvents, now);

    final result = (activities.map((ac) => ac.name!).toList() +
            ((eventsMatched ?? []) + (systemEventsMatched ?? []))
                .map((ev) => ev.title)
                .toList())
        .map((it) => '⬤ $it')
        .toList();

    setState(() {
      _todayEvents = result.length <= 2
          ? result
          : result.isEmpty
              ? null
              : [result.first, '...等${result.length}个事件'];
      _isLoading = false;
    });
  }

  Future<void> _fetchAllSystemCalendars() async {
    final result = await fetchAllSystemCalendars();
    final calendars =
        result.status == Status.ok ? result.value! : <SystemCalendar>[];
    setState(() => _systemCalendars = calendars);
  }

  void _getCachedEvents() {
    List<dynamic>? cachedEvents =
        BoxService.calendarEventListBox.get('calendarEvents');
    List<dynamic>? cachedSystemEvents =
        BoxService.calendarEventListBox.get('calendarSystemEvents');

    // 已有缓存，直接读取
    if (cachedEvents != null && cachedSystemEvents != null) {
      if (cachedEvents.isNotEmpty) {
        setState(() => _events = cachedEvents.cast());
      }

      if (cachedSystemEvents.isNotEmpty) {
        setState(() => _systemEvents = cachedSystemEvents.cast());
      }
    }
  }

  Future<void> _storeToCache(
      List<CalendarEvent> ev, List<CalendarEvent> sev) async {
    // 存入缓存
    await BoxService.calendarEventListBox.put('calendarEvents', ev);
    await BoxService.calendarEventListBox.put('calendarSystemEvents', sev);
  }

  Future<void> _refreshEvents() async {
    if (_eventsRefreshLock) return;

    final result = await _getEvents();
    if (result == null) return;
    final (ev, sev) = result;
    setState(() {
      _events = ev;
      _systemEvents = sev;
      _getTodayEvents();
    });

    await _storeToCache(ev, sev);

    setState(() => _eventsRefreshLock = true);
  }

  Future<(List<CalendarEvent>, List<CalendarEvent>)?> _getEvents() async {
    if (_systemCalendars == null) return null;

    List<CalendarEvent> events = [];
    List<CalendarEvent> systemEvents = [];

    final prefs = await SharedPreferences.getInstance();
    final calendarId = prefs.getString('calendarId');
    for (final calendar in _systemCalendars!) {
      for (final event in calendar.events) {
        if (event.title == null ||
            event.eventId == null ||
            event.calendarId == null) {
          continue;
        }

        final e = CalendarEvent(
            eventId: event.eventId!,
            calendarId: event.calendarId!,
            title: event.title!,
            description: event.description,
            start: event.start,
            end: event.end,
            allDay: event.allDay ?? false,
            location: event.location);

        if (calendar.id == calendarId) {
          events.add(e);
        } else {
          systemEvents.add(e);
        }
      }
    }

    return (events, systemEvents);
  }

  Widget _getChild() {
    const style = TextStyle(color: Colors.grey);
    return SizedBox(
      height: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          const Divider(),
          Text(_isLoading ? '加载中' : '今日事件',
              style: style.copyWith(fontSize: 16)),
          Skeletonizer(
              enabled: _isLoading,
              effect: Values.skeletonizerEffect,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _todayEvents?.firstOrNull ?? '今天没有事件哦',
                      style: style.copyWith(
                          fontSize: _todayEvents?.isEmpty == true ? 12 : 10),
                    ),
                    Text(
                      (_todayEvents?.length == 2
                              ? _todayEvents?.lastOrNull
                              : _todayEvents?.length == 1
                                  ? ''
                                  : null) ??
                          '又是安静的一天~',
                      style: style.copyWith(fontSize: 10),
                    )
                  ]))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_events == null || _systemEvents == null) {
      _getCachedEvents();
    }
    _refreshEvents();

    return Clickable(
        onClick: () {
          if (!_isLoading) {
            pushTo(
                context,
                CalendarPage(
                  activities: widget.activities,
                  events: _events,
                  systemEvents: _systemEvents,
                  storeToCache: _storeToCache,
                ));
            setState(() {});
          }
        },
        child: FCard(
          image: FIcon(FAssets.icons.calendar),
          title: const Text('日历'),
          // subtitle: const Column(
          //   children: [
          //     SizedBox(
          //       height: 8,
          //     ),
          //     Text('看看什么时候放假吧~'),
          //   ],
          // ),
          style: widget.cardStyle,
          child: _getChild(),
        ));
  }
}
