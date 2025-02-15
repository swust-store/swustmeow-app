import 'package:flutter/cupertino.dart';
import 'package:swustmeow/components/instruction/pages/login_page.dart';
import 'package:swustmeow/utils/status.dart';

import '../../components/instruction/button_state.dart';

abstract class AccountService<T extends LoginPage> {
  /// 名称
  String get name;

  /// 用户名
  String get usernameDisplay;

  /// 是否已登录
  bool get isLogin;

  /// 是否已登录的 [ValueNotifier]
  ValueNotifier<bool> get isLoginNotifier;

  /// 专用颜色
  Color get color;

  /// 初始化
  Future<void> init();

  /// 登录
  ///
  /// 返回一个是否登录成功的状态容器。
  Future<StatusContainer<dynamic>> login({
    String? username,
    String? password,
    int retries = 3,
    bool remember = false,
    StatusContainer? lastStatusContainer,
  });

  /// 退出登录
  Future<void> logout();

  /// 获取登录页面实例
  T getLoginPage({
    required ButtonStateContainer sc,
    required Function(ButtonStateContainer sc) onStateChange,
    required Function() onComplete,
    required bool onlyThis,
  });
}
