import 'package:flutter/material.dart';
import 'package:swustmeow/components/qun_card.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';

import '../../services/value_service.dart';

class QunResourcePage extends StatefulWidget {
  const QunResourcePage({super.key});

  @override
  State<StatefulWidget> createState() => _QunResourcePageState();
}

class _QunResourcePageState extends State<QunResourcePage> {
  List<Map<String, String>> _qun = [];

  @override
  void initState() {
    super.initState();
    _qun = GlobalService.serverInfo?.qun ?? [];
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
            '西科群聊导航',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView.separated(
      padding: EdgeInsets.only(
        top: MTheme.radius,
        left: MTheme.radius,
        right: MTheme.radius,
        bottom: 48,
      ),
      shrinkWrap: true,
      separatorBuilder: (context, _) => SizedBox(height: 16),
      itemCount: _qun.length,
      itemBuilder: (context, index) {
        final qun = _qun[index];
        final name = qun['name']!;
        final qid = qun['qid']!;
        final link = qun['link']!;

        return QunCard(name: name, qid: qid, link: link);
      },
    );
  }
}
