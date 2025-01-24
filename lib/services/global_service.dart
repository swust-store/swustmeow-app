import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/api/hitokoto_api.dart';
import 'package:miaomiaoswust/services/duifene_service.dart';
import 'package:miaomiaoswust/services/soa_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/values.dart';

class GlobalService {
  static late DuiFenEService duifeneService;
  static late SOAService soaService;

  static Future<void> load() async {
    await _loadHitokoto();
    await _loadServerInfo();
    duifeneService = DuiFenEService();
    soaService = SOAService();
  }

  static Future<void> _loadHitokoto() async {
    final hitokoto = await getHitokoto();
    final prefs = await SharedPreferences.getInstance();
    final string = hitokoto.value?.hitokoto;
    if (string != null) {
      await prefs.setString('hitokoto', string);
    }
  }

  static Future<void> _loadServerInfo() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();

    final cache = prefs.getString('serverInfo');
    if (cache != null) return;

    try {
      final response = await dio.get(Values.fetchInfoUrl);
      await prefs.setString(
          'serverInfo', json.encode(response.data as Map<String, dynamic>));
    } on Exception catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      await prefs.remove('serverInfo');
    }
  }
}
