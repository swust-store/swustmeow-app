import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/base_event.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/widget.dart';

import '../components/calendar/calendar.dart';
import '../components/calendar/calendar_header.dart';
import '../components/calendar/detail_card.dart';
import '../components/calendar/popovers/add_event/add_event_popover.dart';
import '../data/activities_store.dart';
import '../entity/activity.dart';
import '../entity/activity_type.dart';
import '../entity/calendar_event.dart';
import '../utils/calendar.dart';
import '../utils/common.dart';
import '../utils/status.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage(
      {super.key,
      required this.activities,
      required this.events,
      required this.systemEvents,
      required this.storeToCache});

  final List<Activity> activities;
  final List<CalendarEvent>? events;
  final List<CalendarEvent>? systemEvents;
  final Future<void> Function(List<CalendarEvent>, List<CalendarEvent>)
      storeToCache;

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
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
    _activities = widget.activities;
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: pages);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() => setState(() {}));
    _animationIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _addEventPopoverController = FPopoverController(vsync: this);
    _searchPopoverController = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addEventPopoverController.dispose();
    _animationController.dispose();
    _searchPopoverController.dispose();
    super.dispose();
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
    setState(() => _activities =
        defaultActivities + (extra.value! as List<dynamic>).cast());
  }

  void _onBack() {
    _pageController.animateToPage(_pageController.initialPage,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() => _selectedDate = DateTime.now());
  }

  List<BaseEvent> _onSearch(String query) {
    if (query.trim() == '') return [];
    List<BaseEvent> result = [];
    result.addAll(_activities
        .where((ac) => ac.name?.pureString.contains(query.pureString) == true));
    result.addAll(((widget.events ?? []) + (widget.systemEvents ?? []))
        .where((ev) => ev.title.pureString.contains(query.pureString)));
    return result;
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

  bool _getIsInEvent(DateTime date) => [
        ...?getEventsMatched(widget.events, date),
        ...?getEventsMatched(widget.systemEvents, date)
      ].isNotEmpty;

  Future<void> _onAddEvent(String title, String? description, String? location,
      DateTime start, DateTime end, bool allDay) async {
    final result =
        await addEvent(title, description, location, start, end, allDay);
    if (result.status == Status.ok) {
      if (!mounted) return;
      showSuccessToast(context, '添加事件成功！');

      final event = result.value as CalendarEvent;

      setState(() {
        widget.events?.add(event);
      });

      if (widget.events != null && widget.systemEvents != null) {
        await widget.storeToCache(widget.events!, widget.systemEvents!);
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
      widget.events?.removeWhere((ev) => ev.eventId == eventId);
    });

    if (widget.events != null && widget.systemEvents != null) {
      await widget.storeToCache(widget.events!, widget.systemEvents!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activitiesMatched = _activities
        .where((ac) => ac.isInActivity(_selectedDate))
        .toList()
      ..sort((a, b) => ActivityTypeData.of(b.type)
          .priority
          .compareTo(ActivityTypeData.of(a.type).priority)); // 降序排序;

    final eventsMatched = getEventsMatched(widget.events, _selectedDate);
    final systemEventsMatched =
        getEventsMatched(widget.systemEvents, _selectedDate);

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
        ).withBackground,
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
        ).withBackground,
      ),
    );
  }
}
