import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/core/activity/activity.dart';
import 'package:miaomiaoswust/core/activity/store.dart';
import 'package:miaomiaoswust/core/values.dart';
import 'calendar_grid.dart';
import 'calendar_header.dart';
import 'detail_card.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late FPopoverController _searchPopoverController;
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  static const pages = 1000; // “无限”滑动

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: pages);
    _searchPopoverController = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchPopoverController.dispose();
    super.dispose();
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

  void _onBack() {
    _pageController.animateToPage(_pageController.initialPage,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() => _selectedDate = Values.now);
  }

  List<Activity> _onSearch(String query) {
    if (query.trim() == '') return [];
    return activities.where((ac) => ac.name?.contains(query) == true).toList();
  }

  DateTime _getMonthForPage(int page) {
    final monthDiff = page - pages;
    return DateTime(
      DateTime.now().year,
      DateTime.now().month + monthDiff,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CalendarHeader(
          displayedMonth: _displayedMonth,
          onBack: _onBack,
          onSearch: _onSearch,
          onSelectDate: _onDateSelected,
          searchPopoverController: _searchPopoverController,
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _displayedMonth = _getMonthForPage(index);
              });
            },
            itemBuilder: (context, index) {
              final month = _getMonthForPage(index);
              return CalendarGrid(
                displayedMonth: month,
                selectedDate: _selectedDate,
                activities: activities,
                onDateSelected: _onDateSelected,
              );
            },
          ),
        ),
        Expanded(
          child: SizedBox.expand(
            child: DetailCard(
              selectedDate: _selectedDate,
              activities: activities,
            ),
          ),
        ),
      ],
    );
  }
}
