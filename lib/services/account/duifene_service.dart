import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swustmeow/api/duifene_api.dart';
import 'package:swustmeow/components/instruction/pages/duifene_login_page.dart';
import 'package:swustmeow/entity/duifene/duifene_course.dart';
import 'package:swustmeow/entity/duifene/duifene_homework.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/services/box_service.dart';

import '../../components/instruction/button_state.dart';
import '../../entity/duifene/duifene_sign_container.dart';
import '../../entity/duifene/duifene_test.dart';
import '../../utils/status.dart';
import '../global_service.dart';

class DuiFenEService extends AccountService<DuiFenELoginPage> {
  DuiFenEApiService? _api;

  @override
  String get name => '对分易';

  @override
  String get usernameDisplay =>
      (BoxService.duifeneBox?.get('username') as String?) ?? '';

  @override
  bool get isLogin => (BoxService.duifeneBox?.get('isLogin') as bool?) ?? false;

  @override
  ValueNotifier<bool> isLoginNotifier = ValueNotifier(false);

  @override
  Color get color => Colors.orange;

  @override
  DuiFenELoginPage getLoginPage({
    required ButtonStateContainer sc,
    required Function(ButtonStateContainer sc) onStateChange,
    required Function() onComplete,
    required bool onlyThis,
  }) =>
      DuiFenELoginPage(
          sc: sc,
          onStateChange: onStateChange,
          onComplete: onComplete,
          onlyThis: onlyThis);

  @override
  Future<void> init() async {
    _api ??= DuiFenEApiService();
    await _api?.init();
    await checkLogin();
  }

  /// 获取是否已登录的状态
  Future<bool> checkLogin() async {
    final flag = await _api?.getIsLogin() ?? false;
    final box = BoxService.duifeneBox;
    if (!flag) {
      isLoginNotifier.value = false;
      await box?.put('isLogin', false);

      // 未登录，尝试使用缓存的账号密码登录
      final result = await login();
      final success = result.status == Status.ok;

      isLoginNotifier.value = success;
      await box?.put('isLogin', success);
      return success;
    } else {
      isLoginNotifier.value = true;
      await box?.put('isLogin', true);
      return true;
    }
  }

  /// 登录到对分易
  ///
  /// 返回一个是否登录成功的状态容器。
  @override
  Future<StatusContainer> login({
    String? username,
    String? password,
    int retries = 3,
    bool remember = true,
  }) async {
    if (retries == 0) return const StatusContainer(Status.fail);

    final box = BoxService.duifeneBox;

    if (username == null || password == null) {
      username = box?.get('username');
      password = box?.get('password');
    }

    if (username == null || password == null) {
      return const StatusContainer(Status.notAuthorized);
    }

    final result = await _api?.login(username, password);
    final status = result?.status;

    if (status == null || status != Status.ok) {
      return await login(
        username: username,
        password: password,
        retries: retries - 1,
        remember: remember,
      );
    }

    isLoginNotifier.value = true;
    await box?.put('isLogin', true);
    await box?.put('username', username);
    await box?.put('password', password);
    await box?.put('remember', remember);
    await GlobalService.loadDuiFenECourses();
    return result!;
  }

  /// 退出登录
  @override
  Future<void> logout() async {
    final box = BoxService.duifeneBox;
    // await box.clear();
    isLoginNotifier.value = false;
    await box?.put('isLogin', false);
  }

  /// 获取课程名称列表
  ///
  /// 若中途遇到异常，返回错误信息字符串的状态容器；
  /// 否则正常返回 [DuiFenECourse] 的列表的状态容器。
  Future<StatusContainer<dynamic>> getCourseList() async {
    if (!isLogin) {
      return const StatusContainer(Status.notAuthorized, '未登录');
    }

    final result = await _api?.getCourseList();
    if (result == null || result.status != Status.ok) {
      final r = await login();
      if (r.status != Status.ok) {
        await logout();
        return const StatusContainer(Status.notAuthorized, '登录状态失效');
      }

      return await getCourseList();
    }

    return result;
  }

  /// 检查是否有签到，返回一个签到信息容器
  Future<StatusContainer<DuiFenESignContainer>> checkSignIn(
      DuiFenECourse course) async {
    if (_api == null) return StatusContainer(Status.fail);

    return await _api!.checkSignIn(course);
  }

  /// 签到
  ///
  /// 返回是否签到成功的值。
  Future<bool> signIn(DuiFenESignContainer signContainer) async {
    final code = signContainer.signCode;
    return await _api?.signInWithSignCode(code) ?? false;
  }

  /// 获取在线练习
  ///
  /// 返回一个带有 [DuiFenETest] 的列表的状态容器。
  Future<StatusContainer<List<DuiFenETest>>> getTests(
      DuiFenECourse course) async {
    final result = await _api?.getTests(course);
    if (result == null) return const StatusContainer(Status.fail);
    return result;
  }

  /// 获取所有作业
  ///
  /// 返回一个带有 [DuiFenEHomework] 的列表的状态容器。
  Future<StatusContainer<List<DuiFenEHomework>>> getHomeworks(
      DuiFenECourse course) async {
    final result = await _api?.getHomeworks(course);
    if (result == null) return const StatusContainer(Status.fail);
    return result;
  }
}
