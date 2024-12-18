import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/calendar/calendar.dart';
import '../components/calendar/calendar_header.dart';
import '../components/calendar/detail_card.dart';
import '../components/calendar/popovers/add_event/add_event_popover.dart';
import '../data/activities_store.dart';
import '../entity/activity/activity.dart';
import '../entity/calendar_event.dart';
import '../entity/system_calendar.dart';
import '../utils/calendar.dart';
import '../utils/common.dart';
import '../utils/router.dart';
import '../utils/status.dart';
import 'main_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

// TODO 修复同页面下跨天数据不更新的问题
class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  late PageController _pageController;
  late FPopoverController _addEventPopoverController;
  late AnimationController _animationController;
  late Animation<double> _animationIcon;
  late FPopoverController _searchPopoverController;
  static const pages = 1000;

  List<SystemCalendar>? _systemCalendars;
  List<CalendarEvent>? _events;
  List<CalendarEvent>? _systemEvents;
  bool _eventsRefreshLock = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: pages);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() => setState(() {}));
    _animationIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _addEventPopoverController = FPopoverController(vsync: this);
    _searchPopoverController = FPopoverController(vsync: this);
    _fetchAllSystemCalendars();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addEventPopoverController.dispose();
    _animationController.dispose();
    _searchPopoverController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllSystemCalendars() async {
    final result = await fetchAllSystemCalendars();
    final calendars =
        result.status == Status.ok ? result.value! : <SystemCalendar>[];
    setState(() => _systemCalendars = calendars);
  }

  Future<void> _getCachedEvents() async {
    final cachedEvents = await Values.cache.getFileFromCache('calendarEvents');
    final cachedSystemEvents =
        await Values.cache.getFileFromCache('calendarSystemEvents');

    // 已有缓存，直接读取
    if (cachedEvents != null && cachedSystemEvents != null) {
      getFromFile(FileInfo f) async {
        final b = await f.file.readAsBytes();
        if (b.isEmpty) return <CalendarEvent>[];
        final s = utf8.decode(b);
        final o = json.decode(s);
        final r = <CalendarEvent>[];
        for (Map<String, dynamic> json in o) {
          r.add(CalendarEvent.fromJson(json));
        }
        return r;
      }

      final ev = await getFromFile(cachedEvents);
      final sev = await getFromFile(cachedSystemEvents);
      if (ev.isNotEmpty || sev.isNotEmpty) {
        setState(() {
          _events = ev;
          _systemEvents = sev;
        });
      }
    }
  }

  Future<void> _storeToCache(
      List<CalendarEvent> ev, List<CalendarEvent> sev) async {
    // 存入缓存
    toBytes(List<CalendarEvent> list) {
      final s = list.map((e) => e.toJson()).toList();
      return utf8.encode(json.encode(s));
    }

    await Values.cache.putFile('calendarEvents', toBytes(ev));
    await Values.cache.putFile('calendarSystemEvents', toBytes(sev));
  }

  Future<void> _refreshEvents() async {
    if (_eventsRefreshLock) return;

    final result = await _getEvents();
    if (result == null) return;
    final (ev, sev) = result;
    setState(() {
      _events = ev;
      _systemEvents = sev;
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
            event.calendarId == null) continue;

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

  void _addEventPopoverAnimate() {
    if (!_addEventPopoverController.shown) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  DateTime _getMonthForPage(int page) {
    final monthDiff = page - pages;
    return DateTime(
      DateTime.now().year,
      DateTime.now().month + monthDiff,
    );
  }

  void _onBack() {
    _pageController.animateToPage(_pageController.initialPage,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() => _selectedDate = Values.now);
  }

  List<Activity> _onSearch(String query) {
    if (query.trim() == '') return [];
    return activities.where((ac) => ac.name?.contains(query) == true).toList();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      if (date.month != _displayedMonth.month ||
          date.year != _displayedMonth.year) {
        _displayedMonth = DateTime(date.year, date.month);
        final int diff = (_displayedMonth.year - DateTime.now().year) * 12 +
            _displayedMonth.month -
            DateTime.now().month;
        _pageController.animateToPage(pages + diff,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });
  }

  List<CalendarEvent>? _getEventsMatched(
          List<CalendarEvent>? list, DateTime date) =>
      list?.where((ev) => ev.isInEvent(date)).toList();

  bool _getIsInEvent(DateTime date) => [
        ...?_getEventsMatched(_events, date),
        ...?_getEventsMatched(_systemEvents, date)
      ].isNotEmpty;

  Future<void> _onAddEvent(String title, String? description, String? location,
      DateTime start, DateTime end, bool allDay) async {
    final result =
        await addEvent(title, description, location, start, end, allDay);
    if (result.status == Status.ok) {
      if (context.mounted) {
        showSuccessToast(context, '添加事件成功！');
      }

      final event = result.value as CalendarEvent;

      setState(() {
        _events?.add(event);
      });

      if (_events != null && _systemEvents != null) {
        await _storeToCache(_events!, _systemEvents!);
      }

      _addEventPopoverAnimate();
      _addEventPopoverController.hide();
      return;
    }

    if (context.mounted) {
      showErrorToast(context, result.value ?? '未知错误');
    }
  }

  Future<void> _onRemoveEvent(String eventId) async {
    setState(() {
      _events?.removeWhere((ev) => ev.eventId == eventId);
    });

    if (_events != null && _systemEvents != null) {
      await _storeToCache(_events!, _systemEvents!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_events == null || _systemEvents == null || _systemCalendars == null) {
      _getCachedEvents();
    }
    _refreshEvents();

    final acs = activities;
    final activitiesMatched =
        acs.where((ac) => ac.isInActivity(_selectedDate)).toList();

    final eventsMatched = _getEventsMatched(_events, _selectedDate);
    final systemEventsMatched = _getEventsMatched(_systemEvents, _selectedDate);

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
      content: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: Column(
          children: [
            CalendarHeader(
              displayedMonth: _displayedMonth,
              onBack: _onBack,
              onSearch: _onSearch,
              onSelectDate: _onDateSelected,
              searchPopoverController: _searchPopoverController,
              children: [
                FPopover(
                    controller: _addEventPopoverController,
                    hideOnTapOutside: false,
                    followerBuilder: (context, style, _) => AddEventPopover(
                          onAddEvent: _onAddEvent,
                        ),
                    target: IconButton(
                      onPressed: () {
                        _addEventPopoverAnimate();
                        _addEventPopoverController.toggle();
                      },
                      icon: AnimatedIcon(
                          icon: AnimatedIcons.add_event,
                          progress: _animationIcon),
                    ))
              ],
            ),
            Calendar(
              activities: acs,
              onDateSelected: (value) => setState(() => _selectedDate = value),
              selectedDate: _selectedDate,
              onPageChanged: (index) =>
                  setState(() => _displayedMonth = _getMonthForPage(index)),
              getMonthForPage: _getMonthForPage,
              pageController: _pageController,
              getIsInEvent: _getIsInEvent,
            ),
            Expanded(
              child: SizedBox.expand(
                child: DetailCard(
                  selectedDate: _selectedDate,
                  activities: activitiesMatched,
                  events: eventsMatched,
                  systemEvents: systemEventsMatched,
                  onRemoveEvent: _onRemoveEvent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
