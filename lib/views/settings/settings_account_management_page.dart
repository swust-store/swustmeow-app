import 'package:flutter/material.dart';
import 'package:swustmeow/components/account_card.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';

import '../../services/value_service.dart';

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
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MTheme.radius),
            child: Column(
              children: [
                for (int i = 0; i < GlobalService.services.length; i++) ...[
                  if (i > 0) SizedBox(height: 20.0),
                  AccountCard(
                    service: GlobalService.services[i],
                    color: GlobalService.services[i].color,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
