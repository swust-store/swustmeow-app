import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/utils/time.dart';

import '../../../../entity/calendar_event.dart';

class EditEventPopoverMenu extends StatelessWidget {
  const EditEventPopoverMenu(
      {super.key,
      required this.controller,
      required this.onRemoveEvent,
      required this.event});

  final FPopoverController controller;
  final Future<void> Function(String) onRemoveEvent;
  final CalendarEvent event;

  Future<void> _removeEvent(BuildContext context) async {
    final eventId = event.eventId;
    await onRemoveEvent(eventId);
  }

  List<Widget> _getEventDisplayWidgets(BuildContext context) {
    text(String s) => Text(
          s,
          style:
              TextStyle(color: context.theme.colorScheme.primary, fontSize: 14),
        );

    return [
      text('标题：${event.title}'),
      if (event.description != null) text('描述：${event.description!}'),
      if (event.location != null) text('地点：${event.location!}'),
      if (event.start != null) text('开始：${event.start!.dateStringWithHM}'),
      if (event.end != null) text('结束：${event.end!.dateStringWithHM}')
    ];
  }

  Widget _getRemoveDialog(BuildContext context) {
    pop() => Navigator.of(context).pop();
    return FDialog(
      direction: Axis.horizontal,
      title: const Text('你确定要删除这个事件吗？'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getEventDisplayWidgets(context),
      ),
      actions: [
        FButton(onPress: () => pop(), label: const Text('取消')),
        FButton(
            onPress: () async {
              pop();
              if (context.mounted) {
                await _removeEvent(context);
              }
            },
            style: FButtonStyle.destructive,
            label: const Text('确定'))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.theme.tileGroupStyle;

    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 10.0, 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._getEventDisplayWidgets(context),
            FTileGroup(
                style: FTileGroupStyle(
                    tileStyle: s.tileStyle.copyWith(
                        border: Border.all(color: Colors.transparent)),
                    enabledStyle: s.enabledStyle,
                    disabledStyle: s.disabledStyle,
                    errorStyle: s.errorStyle,
                    borderColor: s.borderColor,
                    borderWidth: s.borderWidth,
                    borderRadius: s.borderRadius),
                children: [
                  FTile(
                    title: const Text(
                      '删除事件',
                      style: TextStyle(color: Colors.red),
                    ),
                    prefixIcon: FIcon(FAssets.icons.trash, color: Colors.red),
                    onPress: () => showAdaptiveDialog(
                        context: context,
                        builder: (context) => _getRemoveDialog(context)),
                  )
                ])
          ],
        ),
      ),
    );
  }
}
