import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/calendar/popovers/add_event/popover_menu_calendar_dialog.dart';
import 'package:miaomiaoswust/components/calendar/popovers/add_event/popover_menu_timepicker_dialog.dart';
import 'package:miaomiaoswust/utils/common.dart';
import 'package:miaomiaoswust/utils/text.dart';
import 'package:miaomiaoswust/utils/time.dart';

class AddEventPopover extends StatefulWidget {
  const AddEventPopover({super.key, required this.onAddEvent});

  final Future<void> Function(String title, String? description,
      String? location, DateTime start, DateTime end, bool allDay) onAddEvent;

  @override
  State<StatefulWidget> createState() => _AddEventPopoverState();
}

class _AddEventPopoverState extends State<AddEventPopover> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _displayedMonthStart;
  late DateTime _displayedMonthEnd;

  bool _allDayState = false;
  DateTime _startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _endDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TimeOfDay _startTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  TimeOfDay _endTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  static const pages = 31 * 12;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _displayedMonthStart = DateTime(_startDate.year, _startDate.month);
    _displayedMonthEnd = DateTime(_endDate.year, _endDate.month);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  DateTime _getMonthForPage(int page) {
    final monthDiff = page - pages;
    return DateTime(
      DateTime.now().year,
      DateTime.now().month + monthDiff,
    );
  }

  Widget _getSelectWidget({
    required String dateString,
    required DateTime date,
    required DateTime displayedMonth,
    required TimeOfDay initialTime,
    required bool isDate,
    required Function(DateTime) onDateSelected,
    required Function(TimeOfDay) onTimeSelected,
    required Function(int) onPageChanged,
  }) =>
      FTappable(
          onPress: () {
            isDate
                ? showAdaptiveDialog(
                    context: context,
                    builder: (context) => PopoverMenuCalendarDialog(
                          dateString: dateString,
                          date: date,
                          displayedMonth: displayedMonth,
                          onDateSelected: onDateSelected,
                          onPageChanged: onPageChanged,
                          getMonthForPage: _getMonthForPage,
                          pages: pages,
                        ))
                : showPopoverMenuTimepickerDialog(context,
                    initialTime: initialTime, onTimeSelected: onTimeSelected);
          },
          child: Text(
            dateString,
            style: const TextStyle(color: Colors.blue),
          ));

  Widget _getDateSelectWidgets({
    required DateTime date,
    required TimeOfDay time,
    required Function(DateTime) onDateSelected,
    required Function(TimeOfDay) onTimeSelected,
    required Function(int) onPageChanged,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _getSelectWidget(
            dateString: date.dateString,
            date: date,
            initialTime: time,
            displayedMonth: _displayedMonthStart,
            isDate: true,
            onDateSelected: onDateSelected,
            onTimeSelected: (_) {},
            onPageChanged: onPageChanged,
          ),
          const SizedBox(
            width: 10,
          ),
          _getSelectWidget(
            dateString: time.hmString,
            date: date,
            initialTime: time,
            displayedMonth: _displayedMonthEnd,
            isDate: false,
            onDateSelected: (_) {},
            onTimeSelected: onTimeSelected,
            onPageChanged: onPageChanged,
          ),
        ],
      );

  Future<void> _submit() async {
    final title = _titleController.value.text.trim().emptyThenNull;
    final description = _descriptionController.value.text.trim().emptyThenNull;
    final location = _locationController.value.text.trim().emptyThenNull;
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day,
        _startTime.hour, _startTime.minute);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day,
        _endTime.hour, _endTime.minute);
    final allDay = _allDayState;

    if (title == null) {
      if (context.mounted) {
        showErrorToast(context, '请输入事件标题！');
      }
      return;
    }

    if (start.isAfter(end) || end.isBefore(start)) {
      if (context.mounted) {
        showErrorToast(context, '结束时间不能在开始时间之前！');
      }
      return;
    }

    await widget.onAddEvent(title, description, location, start, end, allDay);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        '标题',
        FAssets.icons.calendarFold,
        FTextField(
          controller: _titleController,
          maxLines: 1,
        )
      ),
      (
        '全天',
        FAssets.icons.clock,
        FSwitch(
          value: _allDayState,
          onChange: (value) => setState(() => _allDayState = value),
        )
      ),
      if (!_allDayState) ...[
        (
          '开始时间',
          FAssets.icons.dot,
          _getDateSelectWidgets(
              date: _startDate,
              time: _startTime,
              onDateSelected: (date) => setState(() => _startDate = date),
              onTimeSelected: (time) => setState(() => _startTime = time),
              onPageChanged: (index) {
                final m = _getMonthForPage(index);
                setState(() => _displayedMonthStart = m);
              })
        ),
        (
          '结束时间',
          FAssets.icons.dot,
          _getDateSelectWidgets(
              date: _endDate,
              time: _endTime,
              onDateSelected: (date) => setState(() => _endDate = date),
              onTimeSelected: (time) => setState(() => _endTime = time),
              onPageChanged: (index) {
                final m = _getMonthForPage(index);
                setState(() => _displayedMonthEnd = m);
              })
        )
      ],
      (
        '描述',
        FAssets.icons.letterText,
        FTextField(
          controller: _descriptionController,
          maxLines: 2,
        )
      ),
      (
        '地点',
        FAssets.icons.mapPin,
        FTextField(
          controller: _locationController,
          maxLines: 1,
        )
      )
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('添加事件', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          for (final (label, icon, child) in items) ...[
            Row(
              children: [
                Expanded(
                    child: Row(
                  children: [
                    FIcon(icon),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                )),
                SizedBox(
                  width: 200,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: child,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            )
          ],
          FButton(
              onPress: _submit,
              label: const Text(
                '保存',
                style: TextStyle(fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }
}
