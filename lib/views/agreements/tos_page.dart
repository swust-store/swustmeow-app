import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/components/utils/html_view.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';

class TOSPage extends StatefulWidget {
  const TOSPage({super.key});

  @override
  State<StatefulWidget> createState() => _TOSPageState();
}

class _TOSPageState extends State<TOSPage> {
  String? _tosHTML;

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

    final dio = Dio();
    final tosHTML = (await dio.get(tos)).data as String;
    _refresh(() {
      _tosHTML = tosHTML;
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MTheme.radius),
            topRight: Radius.circular(MTheme.radius),
          ),
        ),
        child: _tosHTML == null
            ? Center(child: CircularProgressIndicator(color: MTheme.primary2))
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: HTMLView(html: _tosHTML!),
                ),
              ),
      ),
    );
  }
}
