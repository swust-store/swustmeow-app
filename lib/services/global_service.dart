import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:miaomiaoswust/api/hitokoto_api.dart';
import 'package:miaomiaoswust/data/activities_store.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_course.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_test.dart';
import 'package:miaomiaoswust/entity/run_mode.dart';
import 'package:miaomiaoswust/entity/server_info.dart';
import 'package:miaomiaoswust/services/account/duifene_service.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/services/notification_service.dart';
import 'package:miaomiaoswust/services/background_service.dart';
import 'package:miaomiaoswust/services/tasks/background_task.dart';
import 'package:miaomiaoswust/services/tasks/duifene_task.dart';
import 'package:miaomiaoswust/utils/status.dart';

import '../data/values.dart';
import 'account/soa_service.dart';

class GlobalService {
  static NotificationService? notificationService;
  static SOAService? soaService;
  static DuiFenEService? duifeneService;

  static ValueNotifier<List<Activity>> extraActivities = ValueNotifier([]);
  static ValueNotifier<List<DuiFenECourse>> duifeneCourses = ValueNotifier([]);
  static ValueNotifier<List<DuiFenECourse>> duifeneSelectedCourses =
      ValueNotifier([]);
  static ValueNotifier<List<List<DuiFenETest>>> duifeneTests = ValueNotifier([]);

  static BackgroundService? backgroundService;
  static Map<String, BackgroundTask> backgroundTaskMap = {
    'duifene': DuiFenETask()
  };

  static ValueNotifier<int> duifeneSignTotalCount = ValueNotifier(0);

  static Future<void> load() async {
    debugPrint('加载总服务中...');

    notificationService ??= NotificationService();
    await notificationService!.init();

    await _loadHitokoto();
    await _loadServerInfo();

    soaService ??= SOAService();
    await soaService!.init();
    duifeneService ??= DuiFenEService();
    await duifeneService!.init();

    await loadExtraActivities();
    await loadDuiFenECourses();
    await loadDuiFenETests();

    await loadBackgroundService();
    await loadBackgroundTasks();

    _loadDuiFenETotalSignCount();
  }

  static Future<void> dispose() async {
    await notificationService?.dispose();
    backgroundService?.stop();
  }

  static Future<void> loadBackgroundService() async {
    final box = BoxService.commonBox;
    final runMode =
        (box.get('bgServiceRunMode') as RunMode?) ?? RunMode.foreground;
    final enableNotification =
        (box.get('bgServiceNotification') as bool?) ?? true;
    backgroundService = BackgroundService(
        initialRunMode: runMode, enableNotification: enableNotification);
    await backgroundService!.init();
    await backgroundService!.start();
  }

  static Future<void> loadBackgroundTasks() async {
    final service = FlutterBackgroundService();
    final tasks = <String>[];

    for (final name in backgroundTaskMap.keys) {
      final task = backgroundTaskMap[name];
      if (await task?.shouldAutoStart == true) {
        tasks.add(name);
      }
    }

    for (final taskName in tasks) {
      service.invoke('addTask', {'name': taskName});
    }
  }

  static Future<void> loadExtraActivities() async {
    final result = await getExtraActivities();
    if (result.status == Status.ok) {
      extraActivities.value = result.value!;
    }
  }

  static Future<void> loadDuiFenECourses() async {
    final service = FlutterBackgroundService();

    final result = await duifeneService?.getCourseList();
    if (result != null && result.status == Status.ok) {
      List<DuiFenECourse> value = (result.value! as List<dynamic>).cast();
      duifeneCourses.value = value;
    }

    final box = BoxService.duifeneBox;
    List<DuiFenECourse> selected =
        ((box?.get('coursesSelected') as List<dynamic>?) ?? []).cast();
    duifeneSelectedCourses.value = selected;
    service.invoke(
        'duifeneCourses', {'data': selected.map((s) => s.toJson()).toList()});
  }

  static Future<void> loadDuiFenETests() async {
    final courses = duifeneCourses.value;

    List<List<DuiFenETest>> result = [];
    for (final course in courses) {
      final listResult = await duifeneService?.getTests(course);
      if (listResult == null || listResult.status != Status.ok) continue;

      final list = listResult.value!;
      result.add(list);
    }

    duifeneTests.value = result;
  }

  static void _loadDuiFenETotalSignCount() {
    final box = BoxService.duifeneBox;
    duifeneSignTotalCount.value = (box?.get('signCount') as int?) ?? 0;
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
