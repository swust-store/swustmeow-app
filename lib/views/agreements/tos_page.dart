import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';

class TOSPage extends StatefulWidget {
  const TOSPage({super.key});

  @override
  State<StatefulWidget> createState() => _TOSPageState();
}

class _TOSPageState extends State<TOSPage> {
  String? _tosMarkdown;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = GlobalService.serverInfo;
    if (info == null) return;

    final data = info.agreements;
    final tos = data['tos'] as String;

    final dio = Dio();
    final tosMarkdown = (await dio.get(tos)).data as String;
    _refresh(() {
      _tosMarkdown = tosMarkdown;
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
      header: BaseHeader(title: '用户协议'),
      content: Container(
        color: Colors.white,
        child: _tosMarkdown == null
            ? Center(child: CircularProgressIndicator(color: MTheme.primary2))
            : Markdown(data: _tosMarkdown!),
      ),
    );
  }
}
