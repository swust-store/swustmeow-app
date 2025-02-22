import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/calendar/popovers/calendar_search_popover.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/base_event.dart';
import 'package:swustmeow/services/boxes/calendar_box.dart';
import 'package:swustmeow/utils/text.dart';

import '../components/calendar/calendar.dart';
import '../components/calendar/calendar_header.dart';
import '../components/calendar/detail_card.dart';
import '../components/calendar/popovers/add_event/add_event_popover.dart';
import '../components/utils/base_header.dart';
import '../components/utils/base_page.dart';
import '../data/activities_store.dart';
import '../data/showcase_values.dart';
import '../data/values.dart';
import '../entity/activity.dart';
import '../entity/activity_type.dart';
import '../entity/calendar_event.dart';
import '../entity/system_calendar.dart';
import '../services/value_service.dart';
import '../utils/calendar.dart';
import '../utils/common.dart';
import '../utils/status.dart';

class CalendarPage extends StatefulHookWidget {
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
  List<Activity> _activities = [];
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  late PageController _pageController;
  late FPopoverController _addEventPopoverController;
  late AnimationController _animationController;
  late Animation<double> _animationIcon;
  late FPopoverController _searchPopoverController;
  static const pages = 1000;
  bool _isRefreshing = false;
  late AnimationController _refreshAnimationController;

  // 1. 缓存月份数据计算结果
  final Map<int, DateTime> _monthCache = {};

  @override
  void initState() {
    super.initState();
    _fetchAllSystemCalendars();
    _activities = widget.activities;
    _selectedDate = !Values.showcaseMode ? DateTime.now() : ShowcaseValues.now;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: pages);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() => _refresh(() {}));
    _animationIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _addEventPopoverController = FPopoverController(vsync: this);
    _searchPopoverController = FPopoverController(vsync: this);
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 在初始化时立即加载缓存数据
    _getCachedEvents().then((_) {
      // 加载完缓存后开始静默刷新
      _refreshEvents();
    });
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
    _refreshAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllSystemCalendars() async {
    final result = await fetchAllSystemCalendars();
    final calendars =
        result.status == Status.ok ? result.value! : <SystemCalendar>[];
    setState(() => _systemCalendars = calendars);
  }

  Future<void> _getCachedEvents() async {
    List<dynamic>? cachedEvents = CalendarBox.get('calendarEvents');
    List<dynamic>? cachedSystemEvents = CalendarBox.get('calendarSystemEvents');

    if (cachedEvents != null && cachedSystemEvents != null) {
      setState(() {
        if (cachedEvents.isNotEmpty) {
          _events = cachedEvents.cast();
        }
        if (cachedSystemEvents.isNotEmpty) {
          _systemEvents = cachedSystemEvents.cast();
        }
      });
    }
  }

  Future<void> _storeToCache(
      List<CalendarEvent> ev, List<CalendarEvent> sev) async {
    // 存入缓存
    await CalendarBox.put('calendarEvents', ev);
    await CalendarBox.put('calendarSystemEvents', sev);
  }

  Future<void> _refreshEvents() async {
    if (_eventsRefreshLock) return;
    _eventsRefreshLock = true;

    final result = await _getEvents();
    if (result == null) return;
    final (ev, sev) = result;

    if (!mounted) return;
    setState(() {
      _events = ev;
      _systemEvents = sev;
    });

    await _storeToCache(ev, sev);
  }

  Future<(List<CalendarEvent>, List<CalendarEvent>)?> _getEvents() async {
    if (_systemCalendars == null) return null;

    List<CalendarEvent> events = [];
    List<CalendarEvent> systemEvents = [];

    final calendarId = CalendarBox.get('calendarId');
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
    if (_monthCache.containsKey(page)) {
      return _monthCache[page]!;
    }

    final monthDiff = page - pages;
    final result = DateTime(
      (!Values.showcaseMode ? DateTime.now() : ShowcaseValues.now).year,
      (!Values.showcaseMode ? DateTime.now() : ShowcaseValues.now).month +
          monthDiff,
    );

    _monthCache[page] = result;
    return result;
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    _refresh(() {
      _isRefreshing = true;
      _refreshAnimationController.repeat();
    });
    final extra = await fetchExtraActivities();
    if (extra.status != Status.ok) return;
    _refresh(() => _activities =
        defaultActivities + (extra.value! as List<dynamic>).cast());
    _refresh(() {
      _isRefreshing = false;
      _refreshAnimationController.stop();
      _refreshAnimationController.reset();
    });
  }

  void _onBack() {
    _pageController.animateToPage(_pageController.initialPage,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    _refresh(() => _selectedDate =
        !Values.showcaseMode ? DateTime.now() : ShowcaseValues.now);
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
        final int diff = (_displayedMonth.year -
                    (!Values.showcaseMode ? DateTime.now() : ShowcaseValues.now)
                        .year) *
                12 +
            _displayedMonth.month -
            (!Values.showcaseMode ? DateTime.now() : ShowcaseValues.now).month;
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

  Future<void> _onAddEvent(
    String title,
    String? description,
    String? location,
    DateTime start,
    DateTime end,
    bool allDay,
  ) async {
    if (title == Values.name) {
      showSuccessToast(context, '发现彩蛋，感谢支持${Values.name}~', seconds: 10);
    }

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
    setState(() {
      _events?.removeWhere((ev) => ev.eventId == eventId);
      _systemEvents?.removeWhere((ev) => ev.eventId == eventId);
    });

    if (_events != null && _systemEvents != null) {
      await _storeToCache(_events!, _systemEvents!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '校历',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          suffixIcons: [
            CalendarSearchPopover(
              displayedMonth: _displayedMonth,
              onSearch: _onSearch,
              onSelectDate: _onDateSelected,
              searchPopoverController: _searchPopoverController,
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () async {
                    _onRefresh();
                  },
                  icon: RotationTransition(
                    turns: _refreshAnimationController,
                    child: FaIcon(
                      FontAwesomeIcons.rotateRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                if (_isRefreshing)
                  Positioned(
                    bottom: 5,
                    left: 20 / 2,
                    child: Text(
                      '刷新中...',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        content: Stack(
          children: [
            _buildContent(),
            Positioned(
              bottom: 32,
              right: 16,
              child: FPopover(
                controller: _addEventPopoverController,
                hideOnTapOutside: FHidePopoverRegion.excludeTarget,
                popoverBuilder: (context, style, _) => AddEventPopover(
                  onAddEvent: _onAddEvent,
                  selectedDate: _selectedDate,
                ),
                child: FloatingActionButton(
                  backgroundColor: MTheme.primary2,
                  child: AnimatedIcon(
                    icon: AnimatedIcons.add_event,
                    color: Colors.white,
                    progress: _animationIcon,
                    size: 28,
                  ),
                  onPressed: () async {
                    _addEventPopoverAnimate();
                    await _addEventPopoverController.toggle();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final activitiesMatched = useMemoized(() {
      return _activities.where((ac) => ac.isInActivity(_selectedDate)).toList()
        ..sort((a, b) => ActivityTypeData.of(b.type)
            .priority
            .compareTo(ActivityTypeData.of(a.type).priority));
    }, [_selectedDate, _activities]);

    final eventsMatched = useMemoized(
      () => getEventsMatched(_events, _selectedDate),
      [_events, _selectedDate],
    );

    final systemEventsMatched = useMemoized(
      () => getEventsMatched(_systemEvents, _selectedDate),
      [_systemEvents, _selectedDate],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CalendarHeader(
            displayedMonth: _displayedMonth,
            onBack: _onBack,
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
            child: DetailCard(
              key: ValueKey(_selectedDate),
              selectedDate: _selectedDate,
              activities: activitiesMatched,
              events: eventsMatched,
              systemEvents: systemEventsMatched,
              onRemoveEvent: _onRemoveEvent,
            ),
          )
        ],
      ),
    );
  }
}
