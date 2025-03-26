import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/views/simple_webview_page.dart';

class TOSPage extends StatefulWidget {
  const TOSPage({super.key});

  @override
  State<StatefulWidget> createState() => _TOSPageState();
}

class _TOSPageState extends State<TOSPage> {
  String? _tosURL;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = GlobalService.serverInfo;
    if (info == null) return;

    final data = info.agreements;
    final tos = data['tos2'] as String;

    _refresh(() => _tosURL = tos);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleWebViewPage(initialUrl: _tosURL!);
  }
}
