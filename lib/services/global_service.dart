import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:swustmeow/api/hitokoto_api.dart';
import 'package:swustmeow/data/activities_store.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/entity/duifene/duifene_course.dart';
import 'package:swustmeow/entity/run_mode.dart';
import 'package:swustmeow/entity/server_info.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/services/account/apartment_service.dart';
import 'package:swustmeow/services/account/duifene_service.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/notification_service.dart';
import 'package:swustmeow/services/background_service.dart';
import 'package:swustmeow/services/tasks/background_task.dart';
import 'package:swustmeow/services/tasks/duifene_sign_in_task.dart';
import 'package:swustmeow/utils/status.dart';

import '../data/values.dart';
import '../entity/soa/course/term_date.dart';
import 'account/soa_service.dart';

class GlobalService {
  static Size? size;

  static ServerInfo? serverInfo;

  static NotificationService? notificationService;
  static List<AccountService> services = [];
  static SOAService? soaService;
  static DuiFenEService? duifeneService;
  static ApartmentService? apartmentService;

  static ValueNotifier<Map<String, TermDate>> termDates = ValueNotifier({});
  static ValueNotifier<List<Activity>> extraActivities = ValueNotifier([]);
  static ValueNotifier<List<DuiFenECourse>> duifeneCourses = ValueNotifier([]);
  static ValueNotifier<List<DuiFenECourse>> duifeneSelectedCourses =
      ValueNotifier([]);

  static BackgroundService? backgroundService;
  static Map<String, BackgroundTask> backgroundTaskMap = {
    'duifene': DuiFenESignInTask()
  };

  static ValueNotifier<int> duifeneSignTotalCount = ValueNotifier(0);

  static Future<void> load() async {
    debugPrint('加载总服务中...');

    notificationService ??= NotificationService();
    await notificationService!.init();

    await _loadHitokoto();
    await _loadServerInfo();
    await _loadTermDates();

    soaService ??= SOAService();
    await soaService!.init();
    duifeneService ??= DuiFenEService();
    await duifeneService!.init();
    apartmentService ??= ApartmentService();
    await apartmentService!.init();
    services = [soaService!, duifeneService!, apartmentService!];

    await loadExtraActivities();
    await loadDuiFenECourses();

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

    try {
      final response = await dio.get(Values.fetchInfoUrl);
      final info = ServerInfo.fromJson(response.data as Map<String, dynamic>);
      await box.put('serverInfo', info);
      serverInfo = info;
    } on Exception catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      await box.delete('serverInfo');
    }
  }

  static Future<void> _loadTermDates() async {
    final dio = Dio();
    final box = BoxService.courseBox;
    final commonBox = BoxService.commonBox;
    Map<String, TermDate> result = {};

    try {
      final info = commonBox.get('serverInfo') as ServerInfo?;
      if (info == null) return;
      final response = await dio.get(info.termDatesUrl);
      final data = response.data as Map<String, dynamic>;
      for (final term in data.keys) {
        final start = data[term]['start'] as String;
        final end = data[term]['end'] as String;
        final weeks = data[term]['weeks'] as int;
        result[term] = TermDate(
            start: DateTime.parse(start),
            end: DateTime.parse(end),
            weeks: weeks);
      }
      await box.put('termDates', result);
      termDates.value = result;
    } on Exception catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      await box.delete('termDates');
    }
  }
}
