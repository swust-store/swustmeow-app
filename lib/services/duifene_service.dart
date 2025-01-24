import 'package:flutter/cupertino.dart';
import 'package:miaomiaoswust/api/duifene_api.dart';
import 'package:miaomiaoswust/services/box_service.dart';

import '../utils/status.dart';

class DuiFenEService {
  ValueNotifier<bool> isLogin = ValueNotifier(false);
  late final DuiFenEApiService _api;

  DuiFenEService() {
    _init();
  }

  Future<void> _init() async {
    _api = DuiFenEApiService();
    await _api.init();
    await _checkLogin();
  }

  Future<void> _checkLogin() async {
    final flag = await _api.getIsLogin();
    if (!flag) {
      isLogin.value = false;

      // 未登录，尝试使用缓存的账号密码登录
      final result = await login();
      isLogin.value = result.status == Status.ok;
    } else {
      isLogin.value = true;
    }
  }

  /// 登录到对分易
  ///
  /// 返回一个是否登录成功的状态容器。
  Future<StatusContainer> login(
      {String? username, String? password, int retries = 3}) async {
    if (retries == 0) return const StatusContainer(Status.fail);

    final box = BoxService.duifeneBox;

    if (username == null || password == null) {
      username = box.get('username');
      password = box.get('password');
    }

    if (username == null || password == null) {
      return const StatusContainer(Status.notAuthorized);
    }

    await box.put('username', username);
    await box.put('password', password);

    final result = await _api.login(username, password);
    final status = result.status;

    if (status == Status.ok) {
      isLogin.value = true;
      return result;
    } else {
      return await login(
          username: username, password: password, retries: retries - 1);
    }
  }
}
