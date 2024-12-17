import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/calendar/popovers/add_event/popover_menu_calendar_dialog.dart';
import 'package:miaomiaoswust/utils/calendar.dart';
import 'package:miaomiaoswust/utils/common.dart';
import 'package:miaomiaoswust/utils/text.dart';
import 'package:miaomiaoswust/utils/time.dart';

import '../../../../data/values.dart';
import '../../../../utils/status.dart';
import '../../../clickable.dart';

class AddEventPopover extends StatefulWidget {
  const AddEventPopover(
      {super.key, required this.popoverController, required this.animate});

  final FPopoverController popoverController;
  final Function() animate;

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
  DateTime _startDate = Values.now;
  DateTime _endDate = Values.now;
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
    required bool isDate,
    required Function(DateTime) onDateSelected,
    required Function(int) onPageChanged,
  }) =>
      Clickable(
          onPress: () {
            showAdaptiveDialog(
                context: context,
                builder: (context) => PopoverMenuCalendarDialog(
                      dateString: dateString,
                      date: date,
                      displayedMonth: displayedMonth,
                      isDate: isDate,
                      onDateSelected: onDateSelected,
                      onPageChanged: onPageChanged,
                      getMonthForPage: _getMonthForPage,
                      pages: pages,
                    ));
          },
          child: Text(
            dateString,
            style: const TextStyle(color: Colors.blue),
          ));

  Widget _getDateSelectWidgets(
    DateTime date, {
    required Function(DateTime) onDateSelected,
    required Function(int) onPageChanged,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _getSelectWidget(
              dateString: date.dateString,
              date: date,
              displayedMonth: _displayedMonthStart,
              isDate: true,
              onPageChanged: onPageChanged,
              onDateSelected: onDateSelected),
          const SizedBox(
            width: 10,
          ),
          _getSelectWidget(
              dateString: date.hmString,
              date: date,
              displayedMonth: _displayedMonthEnd,
              isDate: false,
              onPageChanged: onPageChanged,
              onDateSelected: (date) {}),
        ],
      );

  // TODO 做校验
  Future<void> _submit() async {
    final title = _titleController.value.text;
    final description = _descriptionController.value.text;
    final location = _locationController.value.text;
    final start = _startDate;
    final end = _endDate;
    final allDay = _allDayState;

    final result = await addEvent(title, description.emptyThenNull,
        location.emptyThenNull, start, end, allDay);
    if (result.status == Status.ok && context.mounted) {
      showSuccessToast(context, '添加事件成功！');
      widget.animate();
      widget.popoverController.hide();
      return;
    }

    if (context.mounted) {
      showErrorToast(context, result.value ?? '未知错误');
    }
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
          _getDateSelectWidgets(_startDate, onDateSelected: (date) {
            setState(() => _startDate = date);
          }, onPageChanged: (index) {
            final m = _getMonthForPage(index);
            setState(() => _displayedMonthStart = m);
          })
        ),
        (
          '结束时间',
          FAssets.icons.dot,
          _getDateSelectWidgets(_endDate, onDateSelected: (date) {
            setState(() => _endDate = date);
          }, onPageChanged: (index) {
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
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
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
