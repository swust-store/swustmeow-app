import 'package:flutter/material.dart';
import 'package:swustmeow/data/values.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../data/m_theme.dart';
import '../../services/value_service.dart';

class SettingsChangelogPage extends StatelessWidget {
  const SettingsChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '更新日志',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MTheme.radius),
            child: _getContent(),
          ),
        ),
      ),
    );
  }

  Widget _getContent() {
    final changelog = Values.changelog;
    final titles = changelog.keys.toList().reversed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...titles.map(
          (title) {
            final logs = changelog[title]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                ...logs.map(
                  (log) => Text(
                    '• $log',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            );
          },
        )
      ],
    );
  }
}
