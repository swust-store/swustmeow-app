import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:miaomiaoswust/api/duifene_api.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';
import 'package:miaomiaoswust/entity/duifene_course.dart';
import 'package:miaomiaoswust/entity/duifene_sign_container.dart';
import 'package:miaomiaoswust/entity/duifene_status.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:miaomiaoswust/utils/status.dart';
import 'package:miaomiaoswust/utils/text.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../data/values.dart';
import '../../utils/time.dart';
import '../background_service.dart';
import 'background_task.dart';

class DuiFenETask extends BackgroundTask {
  static final _notificationPlugin = FlutterLocalNotificationsPlugin();
  static const threshold = 0.8;
  static DuiFenEStatus _status = DuiFenEStatus.initializing;
  static DuiFenECourse? _currentCourse;
  static DuiFenESignContainer? _currentSignInContainer;
  static int _signCount = 0;
  static DuiFenEApiService? duifeneService;
  static List<CourseEntry> _entries = [];
  static List<DuiFenECourse> _courses = [];
  static final List<String> _signedId = [];

  DuiFenETask() : super(name: '对分易自动签到', duration: const Duration(seconds: 1)) {
    _configureNotification();
  }

  static Future<void> _configureNotification() async {
    const channel = AndroidNotificationChannel(
        BackgroundService.notificationChannelId, '西科喵',
        importance: Importance.high);
    await _notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: androidSettings);
    await _notificationPlugin.initialize(settings);
  }

  void _showNotification(
      {required bool enabled,
      String? title,
      required String content,
      bool enableVibration = false,
      bool standAlone = false}) {
    if (!enabled) return;

    _notificationPlugin.show(
      !standAlone
          ? BackgroundService.notificationId
          : int.parse(DateTime.now()
              .microsecondsSinceEpoch
              .toString()
              .characters
              .toList()
              .reversed
              .join()
              .substring(0, 5)), // 随机通知 ID
      title ?? '对分易自动签到',
      content,
      NotificationDetails(
        android: AndroidNotificationDetails(
            BackgroundService.notificationChannelId, '西科喵',
            icon: 'ic_bg_service_small',
            ongoing: true,
            enableVibration: enableVibration),
      ),
    );
  }

  @override
  Future<bool> get shouldAutoStart async {
    final box = BoxService.duifeneBox;
    return (box?.get('enableAutomaticSignIn') as bool?) ?? false;
  }

  Future<void> _changeStatus(ServiceInstance service, DuiFenEStatus status,
      {String? courseName}) async {
    _status = status;
    await invoke(service, 'duifeneStatus', {
      'status': status.toString(),
      'courseName': courseName,
    });
  }

  /// 获取当前正在上的课的名称
  ///
  /// 如果当前没有课，返回 `null`；
  /// 否则，返回当前课程的名称（去除换行、空格、标点符号后）的纯净字符串。
  String? _getCurrentCourseName() {
    if (_entries.isEmpty) return null;

    final now = DateTime.now();
    final tod = TimeOfDay.now();
    final todayEntries = _entries
        .where((entry) =>
            !entry.checkIfFinished(_entries) && entry.weekday == now.weekday)
        .toList()
      ..sort((a, b) => a.numberOfDay.compareTo(b.numberOfDay));
    for (int index = 0; index < todayEntries.length; index++) {
      final entry = todayEntries[index];
      final time = Values.courseTableTimes[index];
      final [startString, endString] = time.split('\n');
      final [start, end] = [startString, endString]
          .map((s) => timeStringToTimeOfDay(s))
          .toList();

      if ((tod.isAfter(start) || tod.isAtSameTimeAs(start)) &&
          (tod.isBefore(end) || tod.isAtSameTimeAs(end))) {
        return entry.courseName.pureString.withoutPunctuation;
      }
    }
    return null;
  }

  Future<bool> _checkCurrentCourse(
      ServiceInstance service, bool enableNotification) async {
    if (duifeneService == null) return false;

    final isLogin = await duifeneService!.getIsLogin();
    if (!isLogin) {
      _changeStatus(service, DuiFenEStatus.notAuthorized);
      _showNotification(
          enabled: enableNotification,
          content: '登录状态失效，请重新登录',
          enableVibration: true);
      await invoke(service, 'removeTask', {'name': 'duifene'});
      return false;
    }

    final currentCourseName = _getCurrentCourseName();
    final matchedCourses = _courses.where((course) =>
        course.courseName.pureString.withoutPunctuation
            .similarityTo(currentCourseName) >=
        threshold);

    if (matchedCourses.isEmpty) {
      _showNotification(
          enabled: enableNotification, content: '已签到$_signCount次，等待上课...');
      _changeStatus(service, DuiFenEStatus.waiting);
      return false;
    }

    final matched = matchedCourses.first;
    _currentCourse = matched;

    _showNotification(
        enabled: enableNotification,
        content: '已签到$_signCount次，正在监听签到：${matched.courseName}');
    _changeStatus(service, DuiFenEStatus.watching,
        courseName: matched.courseName);
    return true;
  }

  Future<void> _checkSignIn(
      ServiceInstance service, bool enableNotification) async {
    final isInCourse = await _checkCurrentCourse(service, enableNotification);
    if (!isInCourse) {
      _showNotification(
          enabled: enableNotification, content: '已签到$_signCount次，等待上课...');
      _changeStatus(service, DuiFenEStatus.waiting);
      return;
    }

    if (duifeneService == null || _currentCourse == null) return;

    final result = await duifeneService!.checkSignIn(_currentCourse!);
    if (result.status == Status.notAuthorized) {
      await invoke(service, 'removeTask', {'name': 'duifene'});
      _showNotification(
          enabled: enableNotification,
          content: '登录状态失效，请重新登录',
          enableVibration: true);
      _changeStatus(service, DuiFenEStatus.notAuthorized);
    }

    if (result.status != Status.ok) return;

    final container = result.value!;
    _currentSignInContainer = container;
    if (_signedId.contains(_currentSignInContainer!.id)) return;

    await invoke(service, 'duifeneSigned');
    _showNotification(
        enabled: enableNotification,
        content:
            '签到码：${container.signCode} 剩余时间：${container.secondsRemaining} 等待自动签到...',
        enableVibration: true);
    _changeStatus(service, DuiFenEStatus.signing,
        courseName: _currentCourse!.courseName);
  }

  Future<void> _signIn(ServiceInstance service, bool enableNotification) async {
    if (duifeneService == null ||
        _currentCourse == null ||
        _currentSignInContainer == null) {
      return;
    }

    final flag = await duifeneService!
        .signInWithSignCode(_currentSignInContainer!.signCode);
    if (!flag) return;

    _signCount++;
    _signedId.add(_currentSignInContainer!.id);
    _showNotification(
        enabled: true,
        content:
            '${_currentCourse!.courseName}签到成功！签到码：${_currentSignInContainer!.signCode}',
        enableVibration: true,
        standAlone: true);

    _currentSignInContainer = null;
    _showNotification(
        enabled: enableNotification,
        content: '已签到$_signCount次，正在监听签到：${_currentCourse!.courseName}');
    _changeStatus(service, DuiFenEStatus.watching);
  }

  @override
  Future<void> run(ServiceInstance service, bool enableNotification) async {
    if (duifeneService == null) {
      duifeneService ??= DuiFenEApiService();
      await duifeneService!.init();
    }

    service.on('duifeneCourseEntries').listen((event) {
      List<Map<String, dynamic>> entries =
          (event!['data'] as List<dynamic>).cast();
      _entries = entries.map((entry) => CourseEntry.fromJson(entry)).toList();
    });

    service.on('duifeneCourses').listen((event) {
      List<Map<String, dynamic>> s = (event!['data'] as List<dynamic>).cast();
      _courses = s.map((e) => DuiFenECourse.fromJson(e)).toList();
    });

    switch (_status) {
      case DuiFenEStatus.initializing:
        _showNotification(
            enabled: enableNotification, content: '已签到$_signCount次，等待上课...');
        _changeStatus(service, DuiFenEStatus.waiting);
        return;
      case DuiFenEStatus.waiting:
        await _checkCurrentCourse(service, enableNotification);
        return;
      case DuiFenEStatus.watching:
        await _checkSignIn(service, enableNotification);
        return;
      case DuiFenEStatus.signing:
        await _signIn(service, enableNotification);
        return;
      case DuiFenEStatus.stopped:
        _showNotification(
            enabled: enableNotification, content: '已签到$_signCount次，等待上课...');
        _changeStatus(service, DuiFenEStatus.waiting);
      case DuiFenEStatus.notAuthorized:
        return;
    }
  }

  @override
  Future<void> stop(ServiceInstance service, bool enableNotification) async {
    _showNotification(
        enabled: enableNotification, content: '已签到$_signCount次，已停止');
    _changeStatus(service, DuiFenEStatus.stopped);
  }
}
