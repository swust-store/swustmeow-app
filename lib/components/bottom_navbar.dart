import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/interactive_widget.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<StatefulWidget> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final FColorScheme colorScheme = context.theme.colorScheme;

    final List<InteractiveWidget> children = [
      InteractiveWidget(FBottomNavigationBarItem(
          label: const Text('主页'),
          icon: FIcon(
            FAssets.icons.house,
          ))),
      InteractiveWidget(FBottomNavigationBarItem(
        label: const Text('更多'),
        icon: FIcon(
          FAssets.icons.circleEllipsis
        )
      ))
      // InteractiveWidget(
      //   FBottomNavigationBarItem(
      //       label: const Empty(), icon: FIcon(FAssets.icons.orbit)),
      // ),
      // InteractiveWidget(
      //     Container(
      //       margin: context.theme.bottomNavigationBarStyle.padding,
      //       decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         border: Border.all(width: 2, color: colorScheme.primary),
      //       ),
      //       child: FBottomNavigationBarItem(
      //         label: const Empty(),
      //         icon: FIcon(
      //           FAssets.icons.plus,
      //           size: 24,
      //           color: colorScheme.primary,
      //         ),
      //       ),
      //     ),
      //     onChange: () => {},
      //     clickable: false),
      // InteractiveWidget(
      //   FBottomNavigationBarItem(
      //       label: const Empty(), icon: FIcon(FAssets.icons.mail)),
      // ),
      // InteractiveWidget(
      //   FBottomNavigationBarItem(
      //       label: const Empty(), icon: FIcon(FAssets.icons.userRound)),
      // )
    ];

    return FBottomNavigationBar(
      index: index,
      onChange: (index) {
        InteractiveWidget matched =
            children.singleWhere((widget) => children.indexOf(widget) == index);
        if (matched.clickable) setState(() => this.index = index);
        matched.onChange?.call();
      },
      children: children.map((widget) => widget.widget).toList(),
    );
  }
}
