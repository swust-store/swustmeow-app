import 'package:flutter/material.dart';
import 'package:swustmeow/services/global_service.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../data/m_theme.dart';
import '../simple_webview_page.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<StatefulWidget> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  String? _privacyURL;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = GlobalService.serverInfo;
    if (info == null) return;

    final data = info.agreements;
    final privacy = data['privacy2'] as String;

    _refresh(() => _privacyURL = privacy);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleWebViewPage(initialUrl: _privacyURL!);
  }
}
