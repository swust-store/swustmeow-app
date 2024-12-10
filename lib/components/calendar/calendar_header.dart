import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/utils/time.dart';
import 'package:miaomiaoswust/utils/widget.dart';

import '../../core/activity/activity.dart';

class CalendarHeader extends StatefulWidget {
  const CalendarHeader({
    super.key,
    required this.displayedMonth,
    required this.onBack,
    required this.onSearch,
    required this.searchPopoverController,
  });

  final DateTime displayedMonth;
  final Function() onBack;
  final List<Activity> Function(String query) onSearch;
  final FPopoverController searchPopoverController;

  @override
  State<StatefulWidget> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader> {
  final TextEditingController _searchController = TextEditingController();
  List<Activity> searchResult = [];

  @override
  void initState() {
    super.initState();
    searchResult.clear();
  }

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
    const singleHeight = 46;
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
                  hint: '搜搜节日、事件...',
                  maxLines: 1,
                  onChange: (String value) {
                    final result = widget.onSearch(value);
                    setState(() => searchResult = result);
                  },
                ),
                SizedBox(
                    height: (searchResult.isEmpty
                            ? singleHeight
                            : searchResult.length > maxItem
                                ? 5 * singleHeight
                                : searchResult.length * singleHeight)
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
                              if (ds == null) return null;
                              return Row(
                                children: [
                                  FIcon(FAssets.icons.calendarFold),
                                  Text(
                                    activity.name!,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Expanded(
                                    child: Text(
                                        activity
                                            .getParsedDateStart(ds)
                                            .dateString
                                            .replaceAll('.', '-'),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  )
                                ],
                              );
                            }))
              ]),
            )),
        target: IconButton(
            onPressed: widget.searchPopoverController.toggle,
            icon: const Icon(Icons.search)));
  }
}
