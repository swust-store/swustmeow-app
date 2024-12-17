import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/calendar/popovers/edit_event/edit_event_popover_menu.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/entity/system_calendar.dart';
import 'package:miaomiaoswust/utils/calendar.dart';
import 'package:miaomiaoswust/utils/common.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../entity/activity/activity.dart';
import '../../utils/time.dart';

class DetailCard extends StatefulWidget {
  const DetailCard({
    super.key,
    required this.selectedDate,
    required this.activities,
    required this.systemCalendars,
  });

  final DateTime selectedDate;
  final List<Activity> activities;
  final List<SystemCalendar> systemCalendars;

  @override
  State<StatefulWidget> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard>
    with SingleTickerProviderStateMixin {
  late FPopoverController _editEventController;

  @override
  void initState() {
    super.initState();
    _editEventController = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _editEventController.dispose();
    super.dispose();
  }

  String? _getWeekInfo() {
    final d = getCourseWeekNum(widget.selectedDate);
    if (d <= 0) return null;
    const w = ['一', '二', '三', '四', '五', '六', '日'];
    return '教学第${d.padL2}周 周${w[widget.selectedDate.weekday - 1]}';
  }

  // TODO 添加缓存机制
  Future<(List<Event>, List<Event>)> _getEvents() async {
    final List<Event> events = [];
    final List<Event> systemEvents = [];
    final prefs = await SharedPreferences.getInstance();
    final calendarId = prefs.getString('calendarId');
    for (final calendar in widget.systemCalendars) {
      for (final event in calendar.events) {
        if (!isYMDInRange(widget.selectedDate, event.start as DateTime,
            event.end as DateTime)) {
          continue;
        }

        if (event.title == null) continue;

        if (calendar.id == calendarId) {
          events.add(event);
        } else {
          systemEvents.add(event);
        }
      }
    }
    return (events, systemEvents);
  }

  Future<void> _onRemoveEvent(String eventId) async {
    final removeResult = await removeEvent(eventId);
    if (removeResult.status != Status.ok) {
      if (context.mounted) {
        showErrorToast(context, '删除失败：${removeResult.value}');
      }
      return;
    }

    if (context.mounted) {
      showSuccessToast(context, '删除成功');
    }
    setState(() {});
  }

  // TODO 添加删除事件功能
  Widget _buildEventColumn(Event event) => FPopover(
      controller: _editEventController,
      shift: FPortalFollowerShift.flip,
      followerBuilder: (context, style, _) => EditEventPopoverMenu(
            controller: _editEventController,
            onRemoveEvent: _onRemoveEvent,
            event: event,
          ),
      target: Clickable(
          onPress: () => _editEventController.toggle(),
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
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10))
                    ],
                  ))
            ],
          )));

  @override
  Widget build(BuildContext context) {
    final activityMatched = widget.activities
        .where((activity) => activity.isInActivity(widget.selectedDate))
        .toList();
    activityMatched
        .sort((a, b) => b.type.priority.compareTo(a.type.priority)); // 降序排序
    final activity = activityMatched.firstOrNull;
    final isActivity = activity != null && activityMatched.isNotEmpty;
    final displayActivities = activityMatched.where((ac) => ac.name != null);
    final weekInfo = _getWeekInfo();
    final fg = context.theme.colorScheme.foreground;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
            future: _getEvents(),
            builder: (context, snapshot) {
              final (events, systemEvents) =
                  snapshot.data ?? (<Event>[], <Event>[]);
              // TODO 使用可滚动的列表试图
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.selectedDate.year}年${widget.selectedDate.month.padL2}月${widget.selectedDate.day.padL2}日',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (weekInfo != null) Text(weekInfo),
                  const SizedBox(
                    height: 6,
                  ),
                  if (isActivity && displayActivities.isNotEmpty)
                    ...displayActivities.map(
                      (ac) => Text('⬤ ${ac.name}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ac.isFestival && !ac.holiday
                                  ? fg
                                  : ac.type.color)),
                    ),
                  if (events.isNotEmpty)
                    ...events.map((event) => _buildEventColumn(event)),
                  if (systemEvents.isNotEmpty)
                    const SizedBox(
                      height: 8,
                    ),
                  if (systemEvents.isNotEmpty)
                    const Text('来自其他日历', style: TextStyle(color: Colors.grey)),
                  if (systemEvents.isNotEmpty)
                    ...systemEvents.map((event) => _buildEventColumn(event))
                ],
              );
            }),
      ),
    );
  }
}
