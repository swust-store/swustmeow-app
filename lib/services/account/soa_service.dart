import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/api/soa_api.dart';
import 'package:miaomiaoswust/components/instruction/pages/soa_login_page.dart';
import 'package:miaomiaoswust/entity/course/courses_container.dart';
import 'package:miaomiaoswust/entity/soa/optional_course.dart';
import 'package:miaomiaoswust/entity/soa/optional_task_type.dart';
import 'package:miaomiaoswust/services/account/account_service.dart';

import '../../api/swuststore_api.dart';
import '../../utils/status.dart';
import '../box_service.dart';

class SOAService extends AccountService {
  SOAApiService? _api;

  @override
  String get name => '一站式服务';

  @override
  String get usernameDisplay =>
      (BoxService.soaBox.get('username') as String?) ?? '';

  @override
  bool get isLogin => (BoxService.soaBox.get('isLogin') as bool?) ?? false;

  @override
  ValueNotifier<bool> isLoginNotifier = ValueNotifier(false);

  @override
  Type get loginPage => SOALoginPage;

  @override
  Future<void> init() async {
    _api ??= SOAApiService();
    await _api?.init();
  }

  /// 登录到一站式系统并获取凭证 (TGC)
  ///
  /// 若登录成功，返回包含 `TGC` 字符串的状态容器；
  /// 否则，返回包含错误信息字符串的状态容器。
  @override
  Future<StatusContainer<String>> login(
      {String? username,
      String? password,
      int retries = 3,
      bool remember = true}) async {
    if (retries == 0) return const StatusContainer(Status.fail);

    final box = BoxService.soaBox;
    if (username == null || password == null) {
      username = box.get('username') as String?;
      password = box.get('password') as String?;
    }

    if (username == null || password == null) {
      return const StatusContainer(Status.fail, '内部参数错误');
    }

    final loginResult = await loginToSOA(username, password);

    if (loginResult.status == Status.fail) {
      return await login(
          username: username,
          password: password,
          retries: retries - 1,
          remember: remember);
    }

    final tgc = loginResult.value!;
    isLoginNotifier.value = true;

    await box.put('isLogin', true);
    await box.put('tgc', tgc);
    await box.put('username', username);
    await box.put('password', password);
    await box.put('remember', remember);
    return StatusContainer(Status.ok, tgc);
  }

  /// 退出登录
  @override
  Future<void> logout() async {
    final box = BoxService.soaBox;
    isLoginNotifier.value = false;
    final keys = ['isLogin', 'tgc'];
    for (final key in keys) {
      await box.delete(key);
    }
  }

  /// 获取普通课和选课课程表
  ///
  /// 若获取成功，返回一个 [CoursesContainer] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getCourseTables() async {
    final box = BoxService.soaBox;
    final tgc = box.get('tgc') as String?;
    if (tgc == null) {
      return const StatusContainer(Status.notAuthorized, '未登录');
    }

    final result = await _api?.getCourseTables(tgc);
    if (result == null || result.status != Status.ok) {
      return result ?? StatusContainer(Status.fail, '内部错误');
    }

    List<CoursesContainer> r = (result.value as List<dynamic>).cast();
    await BoxService.courseBox.put('courseTables', r);
    return StatusContainer(Status.ok, r);
  }

  /// 根据类别获取选课的课程列表
  ///
  /// 若获取成功，返回一个 [OptionalCourse] 的列表的状态容器；
  /// 否则，返回一个带有错误信息的字符串的状态容器。
  Future<StatusContainer<dynamic>> getOptionalCourses(
      OptionalTaskType taskType) async {
    final box = BoxService.soaBox;
    final tgc = box.get('tgc') as String?;
    if (tgc == null) {
      return const StatusContainer(Status.notAuthorized, '未登录');
    }

    final result = await _api?.getOptionalCourses(tgc, taskType);
    if (result == null || result.status != Status.ok) {
      return result ?? StatusContainer(Status.fail, '内部错误');
    }

    List<OptionalCourse> r = (result.value as List<dynamic>).cast();
    await BoxService.soaBox.put('optionalCourses', r);
    return StatusContainer(Status.ok, r);
  }
}
