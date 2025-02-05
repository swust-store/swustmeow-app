import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/account_card.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/widget.dart';

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
    final services = [GlobalService.soaService, GlobalService.duifeneService];
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
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              child: FTileGroup.builder(
                divider: FTileDivider.full,
                count: services.length,
                tileBuilder: (context, index) =>
                    AccountCard(service: services[index]!),
              ),
            ),
          ).withBackground,
        ));
  }
}
