import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:swustmeow/api/duifene_api.dart';
import 'package:swustmeow/entity/duifene/duifene_course.dart';
import 'package:swustmeow/entity/duifene/duifene_sign_container.dart';
import 'package:swustmeow/entity/duifene/duifene_sign_in_status.dart';
import 'package:swustmeow/services/box_service.dart';
import 'package:swustmeow/services/tasks/notification_manager.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../data/values.dart';
import '../../entity/soa/course/course_entry.dart';
import '../../utils/courses.dart';
import '../../utils/time.dart';
import 'background_task.dart';

class DuiFenESignInTask extends BackgroundTask {
  static const _name = '对分易辅助签到';
  static final _notificationManager =
      NotificationManager(name: _name, notificationId: 924986341);
  static const threshold = 0.8;
  static DuiFenESignInStatus _status = DuiFenESignInStatus.initializing;
  static DuiFenECourse? _currentCourse;
  static DuiFenESignContainer? _currentSignInContainer;
  static int _signCount = 0;
  static DuiFenEApiService? duifeneService;
  static String? _term;
  static List<CourseEntry> _entries = [];
  static List<DuiFenECourse> _courses = [];
  static final List<String> _signedId = [];
  static bool _isSignInNotificationEnabled = true;

  DuiFenESignInTask()
      : super(name: _name, duration: const Duration(seconds: 1)) {
    _notificationManager.configureNotification();
  }

  @override
  Future<bool> get shouldAutoStart async {
    final box = BoxService.duifeneBox;
    return (box?.get('enableAutomaticSignIn') as bool?) ?? false;
  }

  Future<void> _changeStatus(
      ServiceInstance service, DuiFenESignInStatus status,
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
    if (_term == null || _entries.isEmpty) return null;

    final now = DateTime.now();
    final tod = TimeOfDay.now();

    final (i, _) = getWeekNum(_term!, now);
    final todayEntries = _entries
        .where((entry) =>
            i &&
            !checkIfFinished(_term!, entry, _entries) &&
            entry.weekday == now.weekday)
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
      await _changeStatus(service, DuiFenESignInStatus.notAuthorized);
      _notificationManager.showNotification(
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
      _notificationManager.showNotification(
          enabled: enableNotification, content: '已签到$_signCount次，等待上课...');
      await _changeStatus(service, DuiFenESignInStatus.waiting);
      return false;
    }

    final matched = matchedCourses.first;
    _currentCourse = matched;

    _notificationManager.showNotification(
        enabled: enableNotification,
        content: '已签到$_signCount次，正在监听签到：${matched.courseName}');
    await _changeStatus(service, DuiFenESignInStatus.watching,
        courseName: matched.courseName);
    return true;
  }

  Future<void> _checkSignIn(
      ServiceInstance service, bool enableNotification) async {
    final isInCourse = await _checkCurrentCourse(service, enableNotification);
    if (!isInCourse) {
      _notificationManager.showNotification(
          enabled: enableNotification, content: '已签到$_signCount次，等待上课...');
      await _changeStatus(service, DuiFenESignInStatus.waiting);
      return;
    }

    if (duifeneService == null || _currentCourse == null) return;

    final result = await duifeneService!.checkSignIn(_currentCourse!);
    if (result.status == Status.notAuthorized) {
      await invoke(service, 'removeTask', {'name': 'duifene'});
      _notificationManager.showNotification(
          enabled: enableNotification,
          content: '登录状态失效，请重新登录',
          enableVibration: true);
      await _changeStatus(service, DuiFenESignInStatus.notAuthorized);
    }

    if (result.status != Status.ok) return;

    final container = result.value!;
    _currentSignInContainer = container;
    if (_signedId.contains(_currentSignInContainer!.id)) return;

    await invoke(service, 'duifeneSigned');
    _notificationManager.showNotification(
        enabled: enableNotification,
        content:
            '签到码：${container.signCode} 剩余时间：${container.secondsRemaining} 等待签到...',
        enableVibration: true);
    await _changeStatus(service, DuiFenESignInStatus.signing,
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
    _notificationManager.showNotification(
        enabled: true,
        content:
            '${_currentCourse!.courseName}签到成功！签到码：${_currentSignInContainer!.signCode}',
        enableVibration: true,
        standAlone: true);

    _currentSignInContainer = null;
    _notificationManager.showNotification(
        enabled: enableNotification,
        content: '已签到$_signCount次，正在监听签到：${_currentCourse!.courseName}');
    await _changeStatus(service, DuiFenESignInStatus.watching);
  }

  @override
  Future<void> run(ServiceInstance service, bool enableNotification) async {
    if (duifeneService == null) {
      duifeneService ??= DuiFenEApiService();
      await duifeneService!.init();
    }

    service.on('duifeneCurrentCourse').listen((event) {
      String term = event!['term'] as String;
      List<Map<String, dynamic>> entries =
          (event['entries'] as List<dynamic>).cast();
      _term = term;
      _entries = entries.map((entry) => CourseEntry.fromJson(entry)).toList();
    });

    service.on('duifeneCourses').listen((event) {
      List<Map<String, dynamic>> s = (event!['data'] as List<dynamic>).cast();
      _courses = s.map((e) => DuiFenECourse.fromJson(e)).toList();
    });

    service.on('duifeneChangeSignInNotificationStatus').listen((event) {
      bool isEnabled = event!['isEnabled'] as bool;
      _isSignInNotificationEnabled = isEnabled;
    });

    final notificationEnabled =
        enableNotification && _isSignInNotificationEnabled;
    switch (_status) {
      case DuiFenESignInStatus.initializing:
        _notificationManager.showNotification(
            enabled: notificationEnabled, content: '已签到$_signCount次，等待上课...');
        await _changeStatus(service, DuiFenESignInStatus.waiting);
        return;
      case DuiFenESignInStatus.waiting:
        await _checkCurrentCourse(service, notificationEnabled);
        return;
      case DuiFenESignInStatus.watching:
        await _checkSignIn(service, notificationEnabled);
        return;
      case DuiFenESignInStatus.signing:
        await _signIn(service, notificationEnabled);
        return;
      case DuiFenESignInStatus.stopped:
        _notificationManager.showNotification(
            enabled: notificationEnabled, content: '已签到$_signCount次，等待上课...');
        await _changeStatus(service, DuiFenESignInStatus.waiting);
      case DuiFenESignInStatus.notAuthorized:
        return;
    }
  }

  @override
  Future<void> stop(ServiceInstance service, bool enableNotification) async {
    _notificationManager.showNotification(
        enabled: enableNotification, content: '已签到$_signCount次，已停止');
    await _changeStatus(service, DuiFenESignInStatus.stopped);
  }
}
