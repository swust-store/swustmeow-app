import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../data/values.dart';
import '../utils/router.dart';
import '../utils/widget.dart';
import 'main_page.dart';

class SettingsAboutDetailsPage extends StatelessWidget {
  const SettingsAboutDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final components = _getComponents();
    return Transform.flip(
        flipX: Values.isFlipEnabled.value,
        flipY: Values.isFlipEnabled.value,
        child: FScaffold(
            header: FHeader.nested(
              title: const Text(
                '关于',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              prefixActions: [
                FHeaderAction(
                    icon: FIcon(FAssets.icons.chevronLeft),
                    onPress: () {
                      Navigator.of(context).pop();
                    })
              ],
            ),
            content: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: components,
                ),
              ),
            )));
  }

  List<Widget> _getComponents() {
    const titleStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
    const detailsStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
    return joinPlaceholder(gap: 60, widgets: [
      Column(
        children: joinPlaceholder(gap: 20, widgets: [
          const Text(
            '喵喵西科',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          Text(
            Values.instruction,
            style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
          )
        ]),
      ),
      FTileGroup(children: [
        FTile(
          title: const Text(
            '当前版本',
            style: titleStyle,
          ),
          details: Text(
            'v${Values.version}',
            style: detailsStyle,
          ),
          prefixIcon: FIcon(FAssets.icons.layoutGrid),
        ),
        FTile(
          title: Text(
            '检查更新',
            style: titleStyle.copyWith(color: Colors.grey),
          ),
          prefixIcon: FIcon(FAssets.icons.circleArrowUp, color: Colors.grey),
        ),
        // FTile(
        //   title: const Text(
        //     '用户服务协议与隐私协议政策',
        //     style: titleStyle,
        //   ),
        //   prefixIcon: FIcon(FAssets.icons.book),
        // )
      ])
    ]);
  }
}
