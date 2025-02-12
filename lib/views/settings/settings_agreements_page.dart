import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/components/utils/empty.dart';
import 'package:swustmeow/services/global_service.dart';

class SettingsAgreementsPage extends StatefulWidget {
  const SettingsAgreementsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsAgreementsPageState();
}

class _SettingsAgreementsPageState extends State<SettingsAgreementsPage> {
  bool _isLoading = true;
  String? _privacyHTML;
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
    final privacy = data['privacy'] as String;
    final tos = data['tos'] as String;

    final dio = Dio();
    final privacyHTML = (await dio.get(privacy)).data as String;
    final tosHTML = (await dio.get(tos)).data as String;
    _refresh(() {
      _privacyHTML = privacyHTML;
      _tosHTML = tosHTML;
      _isLoading = false;
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
    return Empty();
  }
}
