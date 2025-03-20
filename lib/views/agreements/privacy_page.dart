import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:swustmeow/services/global_service.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../data/m_theme.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<StatefulWidget> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  String? _privacyMarkdown;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = GlobalService.serverInfo;
    if (info == null) return;

    final data = info.agreements;
    final privacy = data['privacy'] as String;

    final dio = Dio();
    final privacyMarkdown = (await dio.get(privacy)).data as String;
    _refresh(() {
      _privacyMarkdown = privacyMarkdown;
    });
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(title: '隐私政策'),
      content: Container(
        color: Colors.white,
        child: _privacyMarkdown == null
            ? Center(child: CircularProgressIndicator(color: MTheme.primary2))
            : Markdown(data: _privacyMarkdown!),
      ),
    );
  }
}
