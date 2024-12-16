import 'package:flutter/material.dart';

import '../../data/activities_store.dart';
import 'calendar_grid.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPageChanged,
    required this.getMonthForPage,
    required this.pageController,
    this.showBadges = true,
  });

  final DateTime selectedDate;
  final Function(DateTime date) onDateSelected;
  final Function(int index) onPageChanged;
  final DateTime Function(int index) getMonthForPage;
  final PageController pageController;
  final bool showBadges;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32 + 50 * 6 - 6,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          final month = getMonthForPage(index);
          return CalendarGrid(
            displayedMonth: month,
            selectedDate: selectedDate,
            activities: activities,
            onDateSelected: onDateSelected,
            showBadges: showBadges,
          );
        },
      ),
    );
  }
}
