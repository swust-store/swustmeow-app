import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:swustmeow/api/library_api.dart';
import 'package:swustmeow/api/hitokoto_api.dart';
import 'package:swustmeow/api/swuststore_api.dart';
import 'package:swustmeow/data/activities_store.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/entity/duifene/duifene_course.dart';
import 'package:swustmeow/entity/run_mode.dart';
import 'package:swustmeow/entity/server_info.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/services/account/apartment_service.dart';
import 'package:swustmeow/services/account/duifene_service.dart';
import 'package:swustmeow/services/account/ykt_service.dart';
import 'package:swustmeow/services/notification_service.dart';
import 'package:swustmeow/services/background_service.dart';
import 'package:swustmeow/services/tasks/background_task.dart';
import 'package:swustmeow/services/tasks/duifene_sign_in_task.dart';
import 'package:swustmeow/services/uri_subscription_service.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/widgets/course_table/course_table_widget_manager.dart';
import 'package:swustmeow/widgets/single_course/single_course_widget_manager.dart';
import 'package:swustmeow/widgets/today_courses/today_courses_widget_manager.dart';

import '../data/showcase_values.dart';
import '../data/values.dart';
import '../entity/account.dart';
import '../entity/soa/course/courses_container.dart';
import '../entity/soa/course/term_date.dart';
import '../utils/courses.dart';
import 'account/soa_service.dart';
import 'boxes/apartment_box.dart';
import 'boxes/common_box.dart';
import 'boxes/course_box.dart';
import 'boxes/duifene_box.dart';
import 'boxes/soa_box.dart';

class GlobalService {
  static MediaQueryData? mediaQueryData;
  static Size? size;

  static UriSubscriptionService? uriSubscriptionService;
  static ServerInfo? serverInfo;
  static StatusContainer<dynamic>? reviewAuthResult;

  static NotificationService? notificationService;
  static List<AccountService> services = [];
  static SOAService? soaService;
  static DuiFenEService? duifeneService;
  static ApartmentService? apartmentService;
  static LibraryApiService? fileServerApiService;
  static YKTService? yktService;

  static ValueNotifier<Map<String, TermDate>> termDates = ValueNotifier({});
  static ValueNotifier<List<Activity>> extraActivities = ValueNotifier([]);
  static ValueNotifier<List<DuiFenECourse>> duifeneCourses = ValueNotifier([]);
  static ValueNotifier<List<DuiFenECourse>> duifeneSelectedCourses =
      ValueNotifier([]);

  static BackgroundService? backgroundService;
  static Map<String, BackgroundTask> backgroundTaskMap = {
    'duifene': DuiFenESignInTask()
  };

  static SingleCourseWidgetManager? singleCourseWidgetManager;
  static TodayCoursesWidgetManager? todayCoursesWidgetManager;
  static CourseTableWidgetManager? courseTableWidgetManager;

  static Future<void> load() async {
    debugPrint('加载总服务中...');

    SWUSTStoreApiService.init();
    await loadCommon();
    loadCachedCoursesContainers();

    notificationService ??= NotificationService();
    notificationService!.init();

    soaService ??= SOAService();
    await soaService!.init();
    duifeneService ??= DuiFenEService();
    await duifeneService!.init();
    apartmentService ??= ApartmentService();
    apartmentService!.init();
    fileServerApiService ??= LibraryApiService();
    fileServerApiService!.init();
    yktService ??= YKTService();
    await yktService!.init();
    services = [soaService!, apartmentService!, yktService!, duifeneService!];

    await _loadReviewAuthResult();

    await loadExtraActivities();
    loadDuiFenECourses();

    await loadBackgroundService();
    await loadBackgroundTasks();

    if (Platform.isAndroid) {
      singleCourseWidgetManager ??= SingleCourseWidgetManager();
      todayCoursesWidgetManager ??= TodayCoursesWidgetManager();
      // courseTableWidgetManager ??= CourseTableWidgetManager();
    }
  }

  static Future<void> dispose() async {
    await uriSubscriptionService?.dispose();
    await notificationService?.dispose();
    backgroundService?.stop();
  }

  static Future<void> loadCommon() async {
    await loadServerInfo().then((_) {
      loadTermDates();
    });
    loadHitokoto();
  }

  static Future<void> _loadReviewAuthResult() async {
    // 给 iOS 审核用
    if (!Platform.isIOS) return;

    if (serverInfo == null) return;
    reviewAuthResult = await SWUSTStoreApiService.reviewAuth();
  }

  static Future<void> loadShowcaseMode() async {
    Values.showcaseMode = true;

    final username = 'testaccount';
    final password = 'testaccount';

    final acc = Account(account: username, password: password);

    for (final service in GlobalService.services) {
      service.isLoginNotifier.value = true;
    }

    final map = {
      'isLogin': true,
      'username': username,
      'password': password,
      'account': acc,
    };
    for (final entry in map.entries) {
      await SOABox.put(entry.key, entry.value);
      await DuiFenEBox.put(entry.key, entry.value);
      await ApartmentBox.put(entry.key, entry.value);
    }
  }

  static Future<void> loadBackgroundService() async {
    final runMode =
        (CommonBox.get('bgServiceRunMode') as RunMode?) ?? RunMode.foreground;
    final enableNotification =
        (CommonBox.get('bgServiceNotification') as bool?) ?? true;
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

  static void loadCachedCoursesContainers() {
    ValueService.customCourses =
        (CourseBox.get('customCourses') as Map<dynamic, dynamic>? ?? {}).cast();

    final cached = _getCachedCoursesContainers();
    if (cached != null && cached.where((c) => c.id == null).isEmpty) {
      final cachedWithCustomCourses =
          cached.map((cc) => cc.withCustomCourses).toList();

      final current = getCurrentCoursesContainer(
          ValueService.activities, cachedWithCustomCourses);
      final (today, currentCourse, nextCourse) =
          getCourse(current.term, current.entries);
      ValueService.needCheckCourses = false;
      ValueService.coursesContainers = cachedWithCustomCourses;
      ValueService.todayCourses = today;
      ValueService.currentCoursesContainer = current;
      ValueService.currentCourse = currentCourse;
      ValueService.nextCourse = nextCourse;
      ValueService.cacheSuccess = true;
      ValueService.isCourseLoading.value = false;
    } else {
      ValueService.cacheSuccess = false;
      ValueService.needCheckCourses = true;
      ValueService.isCourseLoading.value = true;
    }

    List<CoursesContainer>? sharedCache =
        (CourseBox.get('sharedContainers') as List<dynamic>?)?.cast();
    if (sharedCache != null) {
      ValueService.sharedContainers = sharedCache;
    }
  }

  static List<CoursesContainer>? _getCachedCoursesContainers() {
    if (Values.showcaseMode) {
      return ShowcaseValues.coursesContainers;
    }

    List<dynamic>? result = CourseBox.get('courseTables');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  static Future<void> loadExtraActivities() async {
    final result = await getExtraActivities();
    if (result.status == Status.ok) {
      extraActivities.value = result.value!;
    }
  }

  static Future<void> loadDuiFenECourses() async {
    final service = FlutterBackgroundService();

    final result = await duifeneService?.getCourseList(false);
    if (result != null && result.status == Status.ok) {
      List<DuiFenECourse> value = (result.value! as List<dynamic>).cast();
      duifeneCourses.value = value;
    }

    List<DuiFenECourse> selected =
        ((DuiFenEBox.get('coursesSelected') as List<dynamic>?) ?? []).cast();
    duifeneSelectedCourses.value = selected;
    service.invoke(
        'duifeneCourses', {'data': selected.map((s) => s.toJson()).toList()});
  }

  static Future<void> loadHitokoto() async {
    final hitokoto = await getHitokoto();
    final string = hitokoto.value?.hitokoto;
    if (string != null) {
      await CommonBox.put('hitokoto', string);
    }
  }

  static Future<void> loadServerInfo() async {
    final dio = Dio();

    final cached = CommonBox.get('serverInfo') as ServerInfo?;
    if (cached != null) {
      await CommonBox.put('serverInfo', cached);
    }

    try {
      final response = await dio.get(
        Values.fetchInfoUrl,
        options: Options(
          sendTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
        ),
      );
      final info = ServerInfo.fromJson(response.data as Map<String, dynamic>);
      await CommonBox.put('serverInfo', info);
      serverInfo = info;
    } on Exception catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  static Future<void> loadTermDates() async {
    final dio = Dio();
    Map<String, TermDate> result = {};

    final cached = CourseBox.get('termDates') as Map<dynamic, dynamic>?;
    if (cached != null) {
      termDates.value = cached.cast();
    }

    try {
      final info = CommonBox.get('serverInfo') as ServerInfo?;
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
          weeks: weeks,
        );
      }
      await CourseBox.put('termDates', result);
      termDates.value = result;
    } on Exception catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  static Future<void> refreshHomeCourseWidgets() async {
    if (!Platform.isAndroid) return;

    singleCourseWidgetManager?.updateState();
    await singleCourseWidgetManager?.updateWidget();

    todayCoursesWidgetManager?.updateState();
    await todayCoursesWidgetManager?.updateWidget();

    // await courseTableWidgetManager?.updateState();
    // await courseTableWidgetManager?.updateWidget();
  }
}
