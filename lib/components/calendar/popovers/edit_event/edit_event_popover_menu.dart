import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/utils/common.dart';

class EditEventPopoverMenu extends StatelessWidget {
  const EditEventPopoverMenu(
      {super.key,
      required this.controller,
      required this.onRemoveEvent,
      required this.event});

  final FPopoverController controller;
  final Future<void> Function(String) onRemoveEvent;
  final Event event;

  Future<void> _removeEvent(BuildContext context) async {
    final eventId = event.eventId;
    if (eventId == null) {
      showErrorToast(context, '删除失败');
      return;
    }

    await onRemoveEvent(eventId);
  }

  Widget _getRemoveDialog(BuildContext context) {
    pop() => Navigator.of(context).pop();
    return FDialog(
      direction: Axis.horizontal,
      title: const Text('你确定要删除这个事件吗？'),
      body: Text(
        '${event.title} - ${event.description}',
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      actions: [
        FButton(onPress: () => pop(), label: const Text('取消')),
        FButton(
            onPress: () async {
              if (context.mounted) {
                await _removeEvent(context);
              }
              pop();
            },
            style: FButtonStyle.destructive,
            label: const Text('确定'))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: FTileGroup(children: [
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
      ]),
    );
  }
}
