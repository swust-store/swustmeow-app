import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/interactive_widget.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<StatefulWidget> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final FColorScheme colorScheme = context.theme.colorScheme;
    final List<InteractiveWidget> children = [
      InteractiveWidget(
          FBottomNavigationBarItem(
              label: const Text('主页'), icon: FIcon(FAssets.icons.house)),
          null),
      InteractiveWidget(
          FBottomNavigationBarItem(
              label: const Text('圈子'), icon: FIcon(FAssets.icons.orbit)),
          null),
      InteractiveWidget(
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1.8, color: colorScheme.primary),
            ),
            child: FBottomNavigationBarItem(
              label: const SizedBox.shrink(),
              icon: FIcon(
                FAssets.icons.plus,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
          ),
          () => {}),
      InteractiveWidget(
          FBottomNavigationBarItem(
              label: const Text('消息'), icon: FIcon(FAssets.icons.mail)),
          null),
      InteractiveWidget(
          FBottomNavigationBarItem(
              label: const Text('我的'), icon: FIcon(FAssets.icons.userRound)),
          null)
    ];

    return FBottomNavigationBar(
      index: index,
      onChange: (index) {
        setState(() => this.index = index);
        InteractiveWidget matched =
            children.singleWhere((widget) => children.indexOf(widget) == index);
        matched.onChange?.call();
      },
      children: children.map((widget) => widget.widget).toList(),
    );
  }
}
