import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/account_card.dart';
import 'package:miaomiaoswust/services/global_service.dart';
import 'package:miaomiaoswust/utils/widget.dart';

import '../data/values.dart';

class SettingsAccountManagementPage extends StatefulWidget {
  const SettingsAccountManagementPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsAccountManagementPageState();
}

class _SettingsAccountManagementPageState
    extends State<SettingsAccountManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: Values.isFlipEnabled.value,
      flipY: Values.isFlipEnabled.value,
      child: FScaffold(
        contentPad: false,
        header: FHeader.nested(
          title: const Text(
            '账号管理',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          prefixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.chevronLeft),
                onPress: () => Navigator.of(context).pop())
          ],
        ).withBackground,
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: joinPlaceholder(
                gap: 8.0,
                widgets: [
                  GlobalService.soaService,
                  GlobalService.duifeneService
                ]
                    .map((service) => Row(children: [
                          Expanded(child: AccountCard(service: service!))
                        ]))
                    .toList()),
          ),
        ).withBackground,
      ),
    );
  }
}
