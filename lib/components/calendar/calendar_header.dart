import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../entity/activity.dart';
import '../../entity/activity_type.dart';
import '../../entity/date_type.dart';
import '../../entity/base_event.dart';
import '../../utils/time.dart';
import '../../utils/widget.dart';

class CalendarHeader extends StatefulWidget {
  const CalendarHeader({
    super.key,
    required this.displayedMonth,
    required this.onRefresh,
    required this.onBack,
    required this.onSearch,
    required this.onSelectDate,
    required this.searchPopoverController,
    this.children,
  });

  final DateTime displayedMonth;
  final Function() onRefresh;
  final Function() onBack;
  final List<BaseEvent> Function(String query) onSearch;
  final Function(DateTime date) onSelectDate;
  final FPopoverController searchPopoverController;
  final List<Widget>? children;

  @override
  State<StatefulWidget> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader> {
  final TextEditingController _searchController = TextEditingController();
  List<BaseEvent> _searchResult = [];
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
                fontSize: 18, fontFeatures: [FontFeature.tabularFigures()]),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
            color: context.theme.colorScheme.primary,
          ),
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(
              Icons.calendar_month,
            ),
            color: context.theme.colorScheme.primary,
          ),
          _getSearchPopover(),
          if (widget.children != null) ...widget.children!
        ],
      ),
    );
  }

  Widget _getSearchPopover() {
    const dividerHeight = 16;
    const maxItem = 4;
    final result = _searchResult
        .where((r) =>
            r.getName() != null &&
            r.getStart(widget.displayedMonth) != null &&
            r.getEnd(widget.displayedMonth) != null)
        .toList();
    return FPopover(
        controller: widget.searchPopoverController,
        followerBuilder: (context, style, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: joinGap(gap: 16, axis: Axis.vertical, widgets: [
                FTextField(
                  controller: _searchController,
                  hint: '搜节日、事件...',
                  maxLines: 1,
                  autofocus: true,
                  onChange: (String value) {
                    final result = widget.onSearch(value);
                    setState(() => _searchResult = result);
                  },
                ),
                SizedBox(
                    height: (_searchResult.isEmpty
                            ? singleSearchRowHeight // 差错感
                            : _searchResult.length > maxItem
                                ? 5 * singleSearchRowHeight
                                : _searchResult.length * singleSearchRowHeight +
                                    (_searchResult.length - 1) * dividerHeight)
                        .toDouble(),
                    width: double.infinity,
                    child: _searchResult.isEmpty
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
                            itemCount: result.length,
                            itemBuilder: (context, index) {
                              final r = result[index];
                              final d = widget.displayedMonth;
                              final type = r.getType(d);
                              final start = r.getStart(d);
                              final end = r.getEnd(d);

                              if (type == DateType.none ||
                                  (r is Activity &&
                                      ActivityTypeData.of(r.type).icon ==
                                          null)) {
                                return null;
                              }

                              return _getSearchRow(r, type, start, end);
                            }))
              ]),
            )),
        target: IconButton(
            onPressed: () {
              widget.searchPopoverController.toggle();
              _searchController.clear();
              setState(() => _searchResult.clear());
            },
            icon: const Icon(Icons.search),
            color: context.theme.colorScheme.primary));
  }

  Widget _getSearchRow(
      BaseEvent event, DateType type, DateTime? start, DateTime? end) {
    final color = event is Activity
        ? ActivityTypeData.of(event.type).color
        : context.theme.colorScheme.primary;
    final stacked =
        _getStackedDisplayDateWidget(event, color, type, start, end);
    return FTappable(
        onPress: () {
          if (start != null) {
            widget.onSelectDate(start);
            widget.searchPopoverController.hide();
          }
        },
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
                        event is Activity
                            ? ActivityTypeData.of(event.type).icon!
                            : FAssets.icons.calendarFold,
                        color: color,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        event.getName()!,
                        style: TextStyle(fontSize: 18, color: color),
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
                  if (stacked != null) stacked
                ],
              )
            ],
          ),
        ));
  }

  (bool, String) _getSearchDateDiffString(DateTime? start, DateTime? end) {
    final now = DateTime.now();
    final ds = start != null ? now.differenceWithoutHMS(start).inDays : null;
    final de = end != null ? now.differenceWithoutHMS(end).inDays : null;
    if (ds == null || de == null) return (true, '还有??天');
    if (ds == de || ds.abs() < de.abs()) {
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

  Widget? _getStackedDisplayDateWidget(BaseEvent event, Color color,
      DateType type, DateTime? start, DateTime? end) {
    final r = _generateStackedDisplayDateString(
        type, start, end, widget.displayedMonth);
    return r != null
        ? Text(r,
            style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.8)))
        : null;
  }

  Widget _getSearchDateDiffWidget(DateTime? start, DateTime? end) {
    final (isFuture, string) = _getSearchDateDiffString(start, end);
    final op = isFuture ? 0.8 : 0.5;
    return Text(string,
        style: TextStyle(
            fontSize: 16,
            color: context.theme.colorScheme.foreground.withValues(alpha: op)));
  }

  String? _generateStackedDisplayDateString(
      DateType type, DateTime? start, DateTime? end, DateTime date) {
    if (start == null) return null;
    final single = '${start.year}年${start.month.padL2}月${start.day.padL2}日';
    if (end == null) return single;
    final diffDays = end.differenceWithoutHMS(start).inDays + 1;
    final diffWeeks = (diffDays / 7).floor();
    final diff = diffDays < 7
        ? '$diffDays天'
        : '$diffWeeks周${diffDays % 7 != 0 ? '${diffDays - diffWeeks * 7}天' : ''}';
    final dynamicMD = start.month == end.month
        ? '${start.month.padL2}月${start.day.padL2}日-${end.day.padL2}日（共$diff）'
        : '${start.month.padL2}月${start.day.padL2}日-${end.month.padL2}月${end.day.padL2}日（共$diff）';
    final staticYMD = start.year == end.year
        ? '${start.year}年$dynamicMD'
        : '${start.year}年${start.month.padL2}月${start.day.padL2}日-${end.year}年${end.month.padL2}月${end.day.padL2}日（共$diff）';
    switch (type) {
      case DateType.none:
        return null;
      case DateType.single:
        return single;
      case DateType.dynamicMDRange:
        return '${date.year}年$dynamicMD';
      case DateType.staticYMDRange:
        return staticYMD;
    }
  }
}
