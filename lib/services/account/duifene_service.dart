import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/api/duifene_api.dart';
import 'package:miaomiaoswust/components/instruction/pages/duifene_login_page.dart';
import 'package:miaomiaoswust/services/account/account_service.dart';
import 'package:miaomiaoswust/services/box_service.dart';

import '../../utils/status.dart';

class DuiFenEService extends AccountService {
  late final DuiFenEApiService _api;

  @override
  String get name => '对分易';

  @override
  String get usernameDisplay =>
      (BoxService.duifeneBox.get('username') as String?) ?? '';

  @override
  bool get isLogin => (BoxService.duifeneBox.get('isLogin') as bool?) ?? false;

  @override
  ValueNotifier<bool> isLoginNotifier = ValueNotifier(false);

  @override
  Type get loginPage => DuiFenELoginPage;

  @override
  Future<void> init() async {
    _api = DuiFenEApiService();
    await _api.init();
    await _checkLogin();
  }

  Future<void> _checkLogin() async {
    final flag = await _api.getIsLogin();
    if (!flag) {
      isLoginNotifier.value = false;

      // 未登录，尝试使用缓存的账号密码登录
      final result = await login();
      isLoginNotifier.value = result.status == Status.ok;
    } else {
      isLoginNotifier.value = true;
    }
  }

  /// 登录到对分易
  ///
  /// 返回一个是否登录成功的状态容器。
  @override
  Future<StatusContainer> login(
      {String? username,
      String? password,
      int retries = 3,
      bool remember = true}) async {
    if (retries == 0) return const StatusContainer(Status.fail);

    final box = BoxService.duifeneBox;

    if (username == null || password == null) {
      username = box.get('username');
      password = box.get('password');
    }

    if (username == null || password == null) {
      return const StatusContainer(Status.notAuthorized);
    }

    final result = await _api.login(username, password);
    final status = result.status;

    if (status == Status.fail) {
      return await login(
          username: username,
          password: password,
          retries: retries - 1,
          remember: remember);
    }

    isLoginNotifier.value = true;
    await box.put('isLogin', true);
    await box.put('username', username);
    await box.put('password', password);
    await box.put('remember', remember);
    return result;
  }

  /// 退出登录
  @override
  Future<void> logout() async {
    final box = BoxService.duifeneBox;
    // await box.clear();
    isLoginNotifier.value = false;
    await box.put('isLogin', false);
  }
}
