import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/calendar/popovers/edit_event/edit_event_popover_menu.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/entity/calendar_event.dart';
import 'package:miaomiaoswust/utils/calendar.dart';
import 'package:miaomiaoswust/utils/common.dart';
import 'package:miaomiaoswust/utils/status.dart';

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
    const w = ['一', '二', '三', '四', '五', '六', '日'];
    final (i, d) = getCourseWeekNum(widget.selectedDate);
    final s = '周${w[widget.selectedDate.weekday - 1]}';
    if (!i) return s;
    return '教学第${d.padL2}周 - $s';
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
    final controller = FPopoverController(vsync: this);
    return FPopover(
        controller: controller,
        shift: FPortalFollowerShift.none,
        followerBuilder: (context, style, _) => EditEventPopoverMenu(
              controller: controller,
              onRemoveEvent: _onRemoveEvent,
              event: event,
            ),
        target: Clickable(
            onClick: () => controller.toggle(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⬤ ${event.title}'),
                ...[
                  '开始：${event.start!.dateStringWithHM}',
                  '结束：${event.end!.dateStringWithHM}'
                ].map((text) => Row(
                      children: [
                        const SizedBox(
                          width: 18,
                        ),
                        Text(text,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 10))
                      ],
                    ))
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activities.firstOrNull;
    final isActivity = activity != null && widget.activities.isNotEmpty;
    final displayActivities = widget.activities.where((ac) => ac.name != null);
    final weekInfo = _getWeekInfo();
    final fg = context.theme.colorScheme.foreground;
    final key = UniqueKey();

    return FCard(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(
              height: 6,
            ),
            SizedBox(
                height: 200,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (isActivity && displayActivities.isNotEmpty)
                      ...displayActivities.map(
                        (ac) => Text('⬤ ${ac.name}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ac.isFestival && !ac.holiday
                                    ? fg
                                    : ActivityTypeData.of(ac.type).color)),
                      ),
                    ...(widget.events ?? [])
                        .map((event) => _buildEventColumn(event)),
                    if (widget.systemEvents != null &&
                        widget.systemEvents?.isNotEmpty == true) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      const Text('来自其他日历', style: TextStyle(color: Colors.grey))
                    ],
                    ...(widget.systemEvents ?? [])
                        .map((event) => _buildEventColumn(event))
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
