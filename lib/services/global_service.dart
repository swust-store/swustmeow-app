import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/api/hitokoto_api.dart';
import 'package:miaomiaoswust/data/activities_store.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/services/duifene_service.dart';
import 'package:miaomiaoswust/services/soa_service.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/values.dart';

class GlobalService {
  static ValueNotifier<List<Activity>> extraActivities = ValueNotifier([]);
  static DuiFenEService? duifeneService;
  static SOAService? soaService;

  static Future<void> load() async {
    debugPrint('加载 GlobalService 中...');
    await _loadExtraActivities();
    await _loadHitokoto();
    await _loadServerInfo();
    duifeneService ??= DuiFenEService();
    soaService ??= SOAService();
  }

  static Future<void> _loadExtraActivities() async {
    final result = await getExtraActivities();
    if (result.status == Status.ok) {
      extraActivities.value = result.value!;
    }
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
