import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/base_event.dart';
import 'package:swustmeow/utils/text.dart';

import '../components/calendar/calendar.dart';
import '../components/calendar/calendar_header.dart';
import '../components/calendar/detail_card.dart';
import '../components/calendar/popovers/add_event/add_event_popover.dart';
import '../data/activities_store.dart';
import '../entity/activity.dart';
import '../entity/activity_type.dart';
import '../entity/calendar_event.dart';
import '../entity/system_calendar.dart';
import '../services/box_service.dart';
import '../utils/calendar.dart';
import '../utils/common.dart';
import '../utils/status.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.activities});

  final List<Activity> activities;

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  List<SystemCalendar>? _systemCalendars;
  List<CalendarEvent>? _events;
  List<CalendarEvent>? _systemEvents;
  bool _eventsRefreshLock = false;
  List<String>? _todayEvents;
  bool _isLoading = true;
  List<Activity> _activities = [];
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  late PageController _pageController;
  late FPopoverController _addEventPopoverController;
  late AnimationController _animationController;
  late Animation<double> _animationIcon;
  late FPopoverController _searchPopoverController;
  static const pages = 1000;

  @override
  void initState() {
    super.initState();
    _fetchAllSystemCalendars();
    _activities = widget.activities;
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: pages);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() => _refresh(() {}));
    _animationIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _addEventPopoverController = FPopoverController(vsync: this);
    _searchPopoverController = FPopoverController(vsync: this);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addEventPopoverController.dispose();
    _animationController.dispose();
    _searchPopoverController.dispose();
    super.dispose();
  }

  void _getTodayEvents() {
    final now = DateTime.now();

    final activities = widget.activities
        .where((ac) => ac.isInActivity(now))
        .where((ac) =>
            ac.display && ac.name != null && ac.type != ActivityType.today)
        .toList()
      ..sort((a, b) => ActivityTypeData.of(b.type)
          .priority
          .compareTo(ActivityTypeData.of(a.type).priority)); // 降序排序

    final eventsMatched = getEventsMatched(_events, now);
    final systemEventsMatched = getEventsMatched(_systemEvents, now);

    final result = (activities.map((ac) => ac.name!).toList() +
            ((eventsMatched ?? []) + (systemEventsMatched ?? []))
                .map((ev) => ev.title)
                .toList())
        .map((it) => '⬤ $it')
        .toList();

    _refresh(() {
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
    if (!mounted) return;
    _refresh(() => _systemCalendars = calendars);
  }

  Future<void> _getCachedEvents() async {
    List<dynamic>? cachedEvents = BoxService.calendarBox.get('calendarEvents');
    List<dynamic>? cachedSystemEvents =
        await BoxService.calendarBox.get('calendarSystemEvents');

    // 已有缓存，直接读取
    if (cachedEvents != null && cachedSystemEvents != null) {
      if (cachedEvents.isNotEmpty) {
        _refresh(() => _events = cachedEvents.cast());
      }

      if (cachedSystemEvents.isNotEmpty) {
        _refresh(() => _systemEvents = cachedSystemEvents.cast());
      }
    }
  }

  Future<void> _storeToCache(
      List<CalendarEvent> ev, List<CalendarEvent> sev) async {
    // 存入缓存
    await BoxService.calendarBox.put('calendarEvents', ev);
    await BoxService.calendarBox.put('calendarSystemEvents', sev);
  }

  Future<void> _refreshEvents() async {
    if (_eventsRefreshLock) return;

    final result = await _getEvents();
    if (result == null) return;
    final (ev, sev) = result;
    _refresh(() {
      _events = ev;
      _systemEvents = sev;
      _getTodayEvents();
    });

    await _storeToCache(ev, sev);

    _refresh(() => _eventsRefreshLock = true);
  }

  Future<(List<CalendarEvent>, List<CalendarEvent>)?> _getEvents() async {
    if (_systemCalendars == null) return null;

    List<CalendarEvent> events = [];
    List<CalendarEvent> systemEvents = [];

    final box = BoxService.calendarBox;
    final calendarId = box.get('calendarId');
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

  Future<void> _onRefresh() async {
    final extra = await fetchExtraActivities();
    if (extra.status != Status.ok) return;
    _refresh(() => _activities =
        defaultActivities + (extra.value! as List<dynamic>).cast());
  }

  void _onBack() {
    _pageController.animateToPage(_pageController.initialPage,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    _refresh(() => _selectedDate = DateTime.now());
  }

  List<BaseEvent> _onSearch(String query) {
    if (query.trim() == '') return [];
    List<BaseEvent> result = [];
    result.addAll(_activities
        .where((ac) => ac.name?.pureString.contains(query.pureString) == true));
    result.addAll(((_events ?? []) + (_systemEvents ?? []))
        .where((ev) => ev.title.pureString.contains(query.pureString)));
    return result;
  }

  void _onDateSelected(DateTime date) {
    _refresh(() {
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

  bool _getIsInEvent(DateTime date) => [
        ...?getEventsMatched(_events, date),
        ...?getEventsMatched(_systemEvents, date)
      ].isNotEmpty;

  Future<void> _onAddEvent(String title, String? description, String? location,
      DateTime start, DateTime end, bool allDay) async {
    final result =
        await addEvent(title, description, location, start, end, allDay);
    if (result.status == Status.ok) {
      if (!mounted) return;
      showSuccessToast(context, '添加事件成功！');

      final event = result.value as CalendarEvent;

      _refresh(() {
        _events?.add(event);
      });

      if (_events != null && _systemEvents != null) {
        await _storeToCache(_events!, _systemEvents!);
      }

      _addEventPopoverAnimate();
      _addEventPopoverController.hide();
      return;
    }

    if (!mounted) return;
    showErrorToast(context, result.value ?? '未知错误');
  }

  Future<void> _onRemoveEvent(String eventId) async {
    _refresh(() {
      _events?.removeWhere((ev) => ev.eventId == eventId);
    });

    if (_events != null && _systemEvents != null) {
      await _storeToCache(_events!, _systemEvents!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_events == null || _systemEvents == null) {
      _getCachedEvents();
    }
    _refreshEvents();

    final activitiesMatched = _activities
        .where((ac) => ac.isInActivity(_selectedDate))
        .toList()
      ..sort((a, b) => ActivityTypeData.of(b.type)
          .priority
          .compareTo(ActivityTypeData.of(a.type).priority)); // 降序排序;

    final eventsMatched = getEventsMatched(_events, _selectedDate);
    final systemEventsMatched = getEventsMatched(_systemEvents, _selectedDate);

    return Transform.flip(
      flipX: Values.isFlipEnabled.value,
      flipY: Values.isFlipEnabled.value,
      child: FScaffold(
        contentPad: false,
        header: FHeader.nested(
          title: const Text(
            '日历',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          prefixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.chevronLeft),
                onPress: () => Navigator.of(context).pop())
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              CalendarHeader(
                displayedMonth: _displayedMonth,
                onRefresh: _onRefresh,
                onBack: _onBack,
                onSearch: _onSearch,
                onSelectDate: _onDateSelected,
                searchPopoverController: _searchPopoverController,
                children: [
                  FPopover(
                      controller: _addEventPopoverController,
                      hideOnTapOutside: FHidePopoverRegion.excludeTarget,
                      popoverBuilder: (context, style, _) => AddEventPopover(
                            onAddEvent: _onAddEvent,
                          ),
                      child: IconButton(
                        onPressed: () {
                          _addEventPopoverAnimate();
                          _addEventPopoverController.toggle();
                        },
                        icon: AnimatedIcon(
                            icon: AnimatedIcons.add_event,
                            progress: _animationIcon,
                            color: context.theme.colorScheme.primary),
                      ))
                ],
              ),
              Calendar(
                activities: _activities,
                onDateSelected: _onDateSelected,
                selectedDate: _selectedDate,
                onPageChanged: (index) =>
                    _refresh(() => _displayedMonth = _getMonthForPage(index)),
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
      ),
    );
  }
}
