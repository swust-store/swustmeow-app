import 'package:flutter/material.dart';
import 'package:swustmeow/api/apartment_api.dart';
import 'package:swustmeow/components/instruction/pages/apartment_login_page.dart';
import 'package:swustmeow/entity/apaertment/apartment_student_info.dart';
import 'package:swustmeow/entity/apaertment/electricity_bill.dart';
import 'package:swustmeow/entity/auth_token.dart';
import 'package:swustmeow/services/account/account_service.dart';
import 'package:swustmeow/utils/time.dart';

import '../../components/instruction/button_state.dart';
import '../../utils/status.dart';
import '../boxes/apartment_box.dart';

class ApartmentService extends AccountService<ApartmentLoginPage> {
  ApartmentApiService? _api;

  @override
  String get name => '公寓服务';

  @override
  String get usernameDisplay => (ApartmentBox.get('username') as String?) ?? '';

  @override
  bool get isLogin {
    if ((ApartmentBox.get('isLogin') as bool?) != true) return false;
    final authToken = ApartmentBox.get('authToken') as AuthToken?;
    return authToken == null ? false : authToken.expireDate > DateTime.now();
  }

  @override
  ValueNotifier<bool> isLoginNotifier = ValueNotifier(false);

  @override
  Color get color => Colors.green;

  @override
  ApartmentLoginPage getLoginPage({
    required ButtonStateContainer sc,
    required Function(ButtonStateContainer sc) onStateChange,
    required Function() onComplete,
    required bool onlyThis,
  }) =>
      ApartmentLoginPage(
          sc: sc,
          onStateChange: onStateChange,
          onComplete: onComplete,
          onlyThis: onlyThis);

  @override
  Future<void> init() async {
    _api ??= ApartmentApiService();
    await _api?.init();
  }

  /// 登录到公寓中心
  ///
  /// 若登录成功，返回一个带有 [AuthToken] 的状态容器；
  /// 否则，返回一个带有错误信息字符串的状态容器。
  @override
  Future<StatusContainer<dynamic>> login({
    String? username,
    String? password,
    int retries = 3,
    bool remember = true,
    StatusContainer? lastStatusContainer,
  }) async {
    if (retries == 0) {
      return StatusContainer(
          Status.fail, lastStatusContainer?.value ?? '服务器错误，请稍后再试');
    }

    if (username == null || password == null) {
      username = ApartmentBox.get('username') as String?;
      password = ApartmentBox.get('password') as String?;
    }

    if (_api == null) {
      return StatusContainer(Status.fail, '本地服务未启动，请重启应用');
    }

    if (username == null || password == null) {
      return StatusContainer(Status.fail, '内部参数错误');
    }

    final loginResult = await _api!.login(username, password);
    if (loginResult.status == Status.fail) {
      return await login(
        username: username,
        password: password,
        retries: retries - 1,
        remember: remember,
        lastStatusContainer: loginResult,
      );
    }

    final authToken = loginResult.value as AuthToken;
    await ApartmentBox.put('isLogin', true);
    await ApartmentBox.put('username', username);
    await ApartmentBox.put('password', password);
    await ApartmentBox.put('remember', remember);
    await ApartmentBox.put('authToken', authToken);
    return StatusContainer(Status.ok, authToken);
  }

  /// 退出登录
  @override
  Future<void> logout() async {
    await ApartmentBox.delete('isLogin');
    await ApartmentBox.clearCache();
  }

  /// 检查是否已登录，并返回登录后的拼接完成的 ``Authorization`` 字符串
  Future<StatusContainer<dynamic>> _checkLogin() async {
    if (_api == null) return StatusContainer(Status.fail);
    final authTokenResult = await login();
    if (authTokenResult.status != Status.ok) return authTokenResult;
    final authToken = authTokenResult.value as AuthToken;
    final authorization = '${authToken.tokenType} ${authToken.token}';
    return StatusContainer(Status.ok, authorization);
  }

  /// 获取电费
  ///
  /// 若获取成功，返回一个带有 [ElectricityBill] 的状态容器；
  /// 否则，返回一个带有错误信息字符串的状态容器。
  Future<StatusContainer<dynamic>> getElectricityBill() async {
    final r = await _checkLogin();
    if (r.status != Status.ok) return r;

    return await _api!.getElectricityBill(r.value as String);
  }

  /// 获取学生详细信息
  ///
  /// 若获取成功，返回一个带有 [ApartmentStudentInfo] 的状态容器；
  /// 否则，返回一个带有错误信息字符串的状态容器。
  Future<StatusContainer<dynamic>> getStudentInfo() async {
    final r = await _checkLogin();
    if (r.status != Status.ok) return r;

    final result = await _api!.getStudentInfo(r.value as String);
    if (result.status != Status.ok) return result;

    await ApartmentBox.put('studentInfo', result.value as ApartmentStudentInfo);
    return StatusContainer(Status.ok, result.value);
  }
}
