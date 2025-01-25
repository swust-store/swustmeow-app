import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/api/hitokoto_api.dart';
import 'package:miaomiaoswust/data/activities_store.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/entity/server_info.dart';
import 'package:miaomiaoswust/services/background_service.dart';
import 'package:miaomiaoswust/services/account/duifene_service.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/services/notification_service.dart';
import 'package:miaomiaoswust/utils/status.dart';

import '../data/values.dart';
import 'account/soa_service.dart';

class GlobalService {
  static NotificationService? notificationService;
  static BackgroundService? backgroundService;
  static ValueNotifier<List<Activity>> extraActivities = ValueNotifier([]);
  static SOAService? soaService;
  static DuiFenEService? duifeneService;

  static Future<void> load() async {
    debugPrint('加载 GlobalService 中...');

    notificationService ??= NotificationService();
    await notificationService!.init();
    backgroundService ??= BackgroundService();
    await backgroundService!.init();

    await _loadExtraActivities();
    await _loadHitokoto();
    await _loadServerInfo();

    soaService ??= SOAService();
    await soaService!.init();
    duifeneService ??= DuiFenEService();
    await duifeneService!.init();
  }

  static Future<void> _loadExtraActivities() async {
    final result = await getExtraActivities();
    if (result.status == Status.ok) {
      extraActivities.value = result.value!;
    }
  }

  static Future<void> _loadHitokoto() async {
    final hitokoto = await getHitokoto();
    final box = BoxService.commonBox;
    final string = hitokoto.value?.hitokoto;
    if (string != null) {
      await box.put('hitokoto', string);
    }
  }

  static Future<void> _loadServerInfo() async {
    final dio = Dio();
    final box = BoxService.commonBox;

    final cache = box.get('serverInfo') as ServerInfo?;
    if (cache != null) return;

    try {
      final response = await dio.get(Values.fetchInfoUrl);
      await box.put('serverInfo',
          ServerInfo.fromJson(response.data as Map<String, dynamic>));
    } on Exception catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      await box.delete('serverInfo');
    }
  }
}
