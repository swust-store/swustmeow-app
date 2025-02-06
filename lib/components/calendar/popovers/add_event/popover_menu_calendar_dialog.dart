import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/time.dart';

import '../../calendar.dart';

class PopoverMenuCalendarDialog extends StatefulWidget {
  const PopoverMenuCalendarDialog({
    super.key,
    required this.dateString,
    required this.date,
    required this.displayedMonth,
    required this.onDateSelected,
    required this.onPageChanged,
    required this.getMonthForPage,
    required this.pages,
  });

  final String dateString;
  final DateTime date;
  final DateTime displayedMonth;
  final Function(DateTime) onDateSelected;
  final Function(int) onPageChanged;
  final DateTime Function(int) getMonthForPage;
  final int pages;

  @override
  State<StatefulWidget> createState() => _PopoverMenuCalendarDialogState();
}

class _PopoverMenuCalendarDialogState extends State<PopoverMenuCalendarDialog> {
  late PageController _pageController;
  late DateTime _selectedDate = widget.date;
  late DateTime _displayedMonth = widget.displayedMonth;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.pages);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FDialog(
        direction: Axis.horizontal,
        title: const Text('选定一个日期'),
        actions: [_getActionButton('确定', onPress: () {})],
        body: _getCalendar());
  }

  Widget _getActionButton(String label, {required Function() onPress}) =>
      FButton(
          style: FButtonStyle.ghost,
          onPress: () {
            onPress();
            Navigator.of(context).pop();
          },
          label: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ));

  Widget _getCalendar() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_displayedMonth.year}年${_displayedMonth.month.padL2}月',
              style: TextStyle(
                  color: context.theme.colorScheme.primary, fontSize: 16)),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 200,
            child: Calendar(
              activities: const [],
              onDateSelected: (selectedDate) {
                _refresh(() => _selectedDate = selectedDate);
                widget.onDateSelected(selectedDate);
              },
              pageController: _pageController,
              onPageChanged: (index) {
                final m = widget.getMonthForPage(index);
                _refresh(() => _displayedMonth = m);
                widget.onPageChanged(index);
              },
              getMonthForPage: widget.getMonthForPage,
              selectedDate: _selectedDate,
              showBadges: false,
              getIsInEvent: (_) => false,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text('当前选择：${_selectedDate.dateString}',
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                fontSize: 16,
              )),
        ],
      ),
    );
  }
}
