import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../data/values.dart';
import '../../entity/activity/activity.dart';
import '../../entity/activity/activity_date_type.dart';
import '../../utils/time.dart';
import '../../utils/widget.dart';
import '../clickable.dart';

class CalendarHeader extends StatefulWidget {
  const CalendarHeader({
    super.key,
    required this.displayedMonth,
    required this.onBack,
    required this.onSearch,
    required this.onSelectDate,
    required this.searchPopoverController,
  });

  final DateTime displayedMonth;
  final Function() onBack;
  final List<Activity> Function(String query) onSearch;
  final Function(DateTime date) onSelectDate;
  final FPopoverController searchPopoverController;

  @override
  State<StatefulWidget> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader> {
  final TextEditingController _searchController = TextEditingController();
  List<Activity> searchResult = [];
  static const singleSearchRowHeight = 1.0 * 48;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0), // 平衡视觉
      child: Row(
        children: [
          Text(
            '${widget.displayedMonth.year}年${widget.displayedMonth.month.padL2}月',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: widget.onBack,
              icon: const Icon(
                Icons.calendar_month,
              )),
          _getSearchPopover()
        ],
      ),
    );
  }

  Widget _getSearchPopover() {
    const dividerHeight = 16;
    const maxItem = 4;
    return FPopover(
        controller: widget.searchPopoverController,
        followerBuilder: (context, style, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: joinPlaceholder(gap: 16, widgets: [
                FTextField(
                  controller: _searchController,
                  hint: '搜节日、事件...',
                  maxLines: 1,
                  autofocus: true,
                  onChange: (String value) {
                    final result = widget.onSearch(value);
                    setState(() => searchResult = result);
                  },
                ),
                SizedBox(
                    height: (searchResult.isEmpty
                            ? singleSearchRowHeight // 差错感
                            : searchResult.length > maxItem
                                ? 5 * singleSearchRowHeight
                                : searchResult.length * singleSearchRowHeight +
                                    (searchResult.length - 1) * dividerHeight)
                        .toDouble(),
                    width: double.infinity,
                    child: searchResult.isEmpty
                        ? const Align(
                            alignment: Alignment.center,
                            child: Text(
                              '这里什么都木有~',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, _) =>
                                Divider(color: context.theme.colorScheme.muted),
                            itemCount: searchResult
                                .where((ac) =>
                                    ac.getDateString(widget.displayedMonth) !=
                                        null &&
                                    ac.name != null)
                                .length,
                            itemBuilder: (context, index) {
                              final activity = searchResult[index];
                              final (type, (start, end)) =
                                  activity.getDateRange(widget.displayedMonth);
                              if (start == null ||
                                  end == null ||
                                  type == ActivityDateType.none ||
                                  activity.type.icon == null) {
                                return null;
                              }

                              return _getSearchRow(activity, type, start, end);
                            }))
              ]),
            )),
        target: IconButton(
            onPressed: () {
              widget.searchPopoverController.toggle();
              _searchController.clear();
              setState(() => searchResult.clear());
            },
            icon: const Icon(Icons.search)));
  }

  Widget _getSearchRow(
      Activity activity, ActivityDateType type, DateTime start, DateTime end) {
    return Clickable(
        child: SizedBox(
          height: singleSearchRowHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FIcon(
                        activity.type.icon!,
                        color: activity.type.color,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        activity.name!,
                        style:
                            TextStyle(fontSize: 18, color: activity.type.color),
                      )
                    ],
                  ),
                  _getSearchDateDiffWidget(start, end)
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 28,
                  ),
                  _getStackedDisplayDateWidget(activity, type, start, end)
                ],
              )
            ],
          ),
        ),
        onPress: () {
          widget.onSelectDate(start);
          widget.searchPopoverController.hide();
        });
  }

  (bool, String) _getSearchDateDiffString(DateTime start, DateTime end) {
    final ds = Values.now.differenceWithoutHMS(start).inDays;
    final de = Values.now.differenceWithoutHMS(end).inDays;
    if (ds == de || ds < de) {
      return ds == 0
          ? (true, '就是今天')
          : ds < 0
              ? (true, '还有${-ds}天')
              : (false, '已经$ds天');
    } else {
      return de == 0
          ? (true, '今天结束')
          : de < 0
              ? (true, '还有${-de}天')
              : (false, '已经$de天');
    }
  }

  Widget _getStackedDisplayDateWidget(
      Activity activity, ActivityDateType type, DateTime start, DateTime end) {
    return Text(
        _generateStackedDisplayDateString(
            type, start, end, widget.displayedMonth)!,
        style: TextStyle(
            fontSize: 13, color: activity.type.color.withOpacity(0.8)));
  }

  Widget _getSearchDateDiffWidget(DateTime start, DateTime end) {
    final (isFuture, string) = _getSearchDateDiffString(start, end);
    final op = isFuture ? 0.8 : 0.5;
    return Text(string,
        style: TextStyle(
            fontSize: 16,
            color: context.theme.colorScheme.foreground.withOpacity(op)));
  }

  String? _generateStackedDisplayDateString(
      ActivityDateType type, DateTime start, DateTime? end, DateTime date) {
    final single = '${start.year}年${start.month.padL2}月${start.day.padL2}日';
    if (end == null) return single;
    final diff = end.differenceWithoutHMS(start).inDays + 1;
    final dynamicMD = start.month == end.month
        ? '${start.month.padL2}月${start.day.padL2}日-${end.day.padL2}日（共$diff天）'
        : '${start.month.padL2}月${start.day.padL2}日-${end.month.padL2}月${end.day.padL2}日（共$diff天）';
    final staticYMD = start.year == end.year
        ? '${start.year}年$dynamicMD'
        : '${start.year}年${start.month.padL2}月${start.day.padL2}日-${end.year}年${end.month.padL2}月${end.day.padL2}日（共$diff天）';
    switch (type) {
      case ActivityDateType.none:
        return null;
      case ActivityDateType.single:
        return single;
      case ActivityDateType.dynamicMDRange:
        return '${date.year}年$dynamicMD';
      case ActivityDateType.staticYMDRange:
        return staticYMD;
    }
  }
}
