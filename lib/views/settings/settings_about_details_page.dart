import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';

import '../../data/values.dart';
import '../../services/value_service.dart';
import '../../utils/widget.dart';

class SettingsAboutDetailsPage extends StatelessWidget {
  const SettingsAboutDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final components = _getComponents();

    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '关于',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: components),
          ),
        ),
      ),
    );
  }

  List<Widget> _getComponents() {
    return joinGap(
      gap: 60,
      axis: Axis.vertical,
      widgets: [
        Column(
          children: joinGap(
            gap: 20,
            axis: Axis.vertical,
            widgets: [
              Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset('assets/icon/icon.png'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    Values.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  Text(
                    '版本：v${Values.version}',
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: 14),
                  )
                ],
              ),
              Text(
                Values.instruction,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              )
            ],
          ),
        ),
      ],
    );
  }
}
