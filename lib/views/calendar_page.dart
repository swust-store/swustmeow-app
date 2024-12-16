import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/data/values.dart';

import '../components/calendar/calendar.dart';
import '../components/calendar/calendar_header.dart';
import '../components/calendar/detail_card.dart';
import '../components/calendar/popover_menu.dart';
import '../data/activities_store.dart';
import '../entity/activity/activity.dart';
import '../entity/system_calendar.dart';
import '../utils/calendar.dart';
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
  late FPopoverController _controller;
  late AnimationController _animationController;
  late Animation<double> _animationIcon;
  late FPopoverController _searchPopoverController;
  static const pages = 1000;

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
    _controller = FPopoverController(vsync: this);
    _searchPopoverController = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    _animationController.dispose();
    _searchPopoverController.dispose();
    super.dispose();
  }

  void _animate() {
    if (!_controller.shown) {
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

  Future<List<SystemCalendar>> _getCalendars() async {
    final result = await fetchAllSystemCalendars();
    return result.status == Status.ok ? result.value! : [];
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
      content: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: Stack(
          children: [
            Column(
              children: [
                CalendarHeader(
                  displayedMonth: _displayedMonth,
                  onBack: _onBack,
                  onSearch: _onSearch,
                  onSelectDate: _onDateSelected,
                  searchPopoverController: _searchPopoverController,
                  children: [
                    FPopover(
                        controller: _controller,
                        hideOnTapOutside: false,
                        followerBuilder: (context, style, _) =>
                            PopoverMenu(popoverController: _controller),
                        target: IconButton(
                          onPressed: () {
                            _animate();
                            _controller.toggle();
                          },
                          icon: AnimatedIcon(
                              icon: AnimatedIcons.add_event,
                              progress: _animationIcon),
                        ))
                  ],
                ),
                Calendar(
                  onDateSelected: (value) =>
                      setState(() => _selectedDate = value),
                  selectedDate: _selectedDate,
                  onPageChanged: (index) =>
                      setState(() => _displayedMonth = _getMonthForPage(index)),
                  getMonthForPage: _getMonthForPage,
                  pageController: _pageController,
                ),
                Expanded(
                  child: FutureBuilder(
                      future: _getCalendars(),
                      builder: (context, snapshot) => SizedBox.expand(
                            child: DetailCard(
                              selectedDate: _selectedDate,
                              activities: activities,
                              systemCalendars: snapshot.data ?? [],
                            ),
                          )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
