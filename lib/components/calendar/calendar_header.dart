import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/utils/widget.dart';

import '../../core/activity/activity.dart';

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
            '${widget.displayedMonth.year}年${widget.displayedMonth.month.toString().padLeft(2, '0')}月',
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
    const singleHeight = 28;
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
                            ? singleHeight // 差错感
                            : searchResult.length > maxItem
                                ? 5 * singleHeight
                                : searchResult.length * singleHeight +
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
                              final ds =
                                  activity.getDateString(widget.displayedMonth);
                              if (ds == null || activity.type.icon == null) {
                                return null;
                              }

                              return Clickable(
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FIcon(activity.type.icon!,
                                          color: activity.type.color),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                            ' ${activity.name!}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: activity.type.color),
                                          )),
                                      Expanded(
                                        child: Text(
                                            activity
                                                .getParsedDateStart(ds)
                                                .dateString
                                                .replaceAll('.', '-'),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: activity.type.color
                                                    .withOpacity(0.8))),
                                      )
                                    ],
                                  ), onPress: () {
                                widget.onSelectDate(
                                    activity.getParsedDateStart(ds));
                                widget.searchPopoverController.hide();
                              });
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
}
