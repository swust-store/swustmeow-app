import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/calendar/popovers/edit_event_popover_menu.dart';
import 'package:swustmeow/entity/calendar_event.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/calendar.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/courses.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/widget.dart';

import '../../entity/activity.dart';
import '../../entity/activity_type.dart';
import '../../utils/time.dart';

class DetailCard extends StatefulWidget {
  const DetailCard({
    super.key,
    required this.selectedDate,
    required this.activities,
    required this.events,
    required this.systemEvents,
    required this.onRemoveEvent,
  });

  final DateTime selectedDate;
  final List<Activity> activities;
  final List<CalendarEvent>? events;
  final List<CalendarEvent>? systemEvents;
  final Future<void> Function(String) onRemoveEvent;

  @override
  State<StatefulWidget> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> with TickerProviderStateMixin {
  String? _getWeekInfo() {
    const weeks = ['一', '二', '三', '四', '五', '六', '日'];
    final s = '周${weeks[widget.selectedDate.weekday - 1]}';
    final terms = ValueService.coursesContainers.map((c) => c.term).toList();
    if (terms.isEmpty) return s;

    List<int> result = [];
    for (final term in terms) {
      final (i, w) = getWeekNum(term, widget.selectedDate);
      if (i) result.add(w);
    }

    if (result.isEmpty) return s;
    return '教学第${result.first.padL2}周 - $s';
  }

  Future<void> _onRemoveEvent(String eventId) async {
    final removeResult = await removeEvent(eventId);

    if (!mounted) return;

    if (removeResult.status != Status.ok) {
      showErrorToast(context, '删除失败：${removeResult.value}');
      return;
    }

    showSuccessToast(context, '删除成功');
    await widget.onRemoveEvent(eventId);

    setState(() {});
  }

  Widget _buildEventColumn(CalendarEvent event) {
    final popoverController = FPopoverController(vsync: this);
    final color = Colors.black;
    return FPopover(
      controller: popoverController,
      shift: FPortalShift.none,
      popoverBuilder: (context, style, _) => EditEventPopoverMenu(
        onRemoveEvent: _onRemoveEvent,
        event: event,
      ),
      child: FTappable(
        onPress: () => popoverController.toggle(),
        child: _buildEventCard(
          color,
          80,
          [
            Text(
              event.title,
              style: TextStyle(
                color: color,
              ),
            ),
            Text(
              '开始：${event.start!.dateStringWithHM}',
              style:
                  TextStyle(color: color.withValues(alpha: 0.6), fontSize: 12),
            ),
            Text(
              '结束：${event.end!.dateStringWithHM}',
              style:
                  TextStyle(color: color.withValues(alpha: 0.6), fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Color color, double height, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(''),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activities.firstOrNull;
    final isActivity = activity != null && widget.activities.isNotEmpty;
    final displayActivities = widget.activities.where((ac) => ac.name != null);
    final weekInfo = _getWeekInfo();
    final fg = context.theme.colorScheme.foreground;

    Color getColor(Activity ac) =>
        ac.isFestival && !ac.holiday ? fg : ActivityTypeData.of(ac.type).color;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        key: Key(
          DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: joinGap(
          gap: 16.0,
          axis: Axis.vertical,
          widgets: [
            Text(
              '${widget.selectedDate.year}年${widget.selectedDate.month.padL2}月${widget.selectedDate.day.padL2}日',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()]),
            ),
            if (weekInfo != null)
              Text(
                weekInfo,
                style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            if (isActivity && displayActivities.isNotEmpty)
              ...displayActivities.map(
                (ac) => _buildEventCard(
                  getColor(ac),
                  40,
                  [
                    Text(
                      ac.name ?? '未知事件',
                      style: TextStyle(color: getColor(ac)),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ...(widget.events ?? []).map((event) => _buildEventColumn(event)),
            ...(widget.systemEvents ?? [])
                .map((event) => _buildEventColumn(event)),
            SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
