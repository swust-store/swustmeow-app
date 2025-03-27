import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/html_view.dart';
import 'package:swustmeow/data/privacy_text.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../data/m_theme.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<StatefulWidget> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(
        title: Text(
          '隐私政策',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MTheme.radius),
            topRight: Radius.circular(MTheme.radius),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HTMLView(html: privacyHTMLText),
          ),
        ),
      ),
    );
  }
}
