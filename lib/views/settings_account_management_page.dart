import 'package:flutter/material.dart';
import 'package:swustmeow/components/account_card.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';

import '../services/value_service.dart';

class SettingsAccountManagementPage extends StatefulWidget {
  const SettingsAccountManagementPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsAccountManagementPageState();
}

class _SettingsAccountManagementPageState
    extends State<SettingsAccountManagementPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final services = [
      (GlobalService.soaService, MTheme.primary2),
      (GlobalService.duifeneService, Colors.orange),
    ];

    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '账号管理',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        content: Padding(
          padding: EdgeInsets.all(MTheme.radius),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            clipBehavior: Clip.none,
            separatorBuilder: (context, _) => SizedBox(height: 16.0),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final (service, color) = services[index];
              return AccountCard(service: service!, color: color);
            },
          ),
        ),
      ),
    );
  }
}
