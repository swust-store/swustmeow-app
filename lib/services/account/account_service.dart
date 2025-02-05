import 'package:flutter/cupertino.dart';
import 'package:swustmeow/utils/status.dart';

abstract class AccountService {
  /// 名称
  String get name;

  /// 用户名
  String get usernameDisplay;

  /// 是否已登录
  bool get isLogin;

  /// 是否已登录的 [ValueNotifier]
  ValueNotifier<bool> get isLoginNotifier;

  /// 登录页面
  Type get loginPage;

  /// 初始化
  Future<void> init();

  /// 登录
  ///
  /// 返回一个是否登录成功的状态容器。
  Future<StatusContainer<dynamic>> login(
      {String? username,
      String? password,
      int retries = 3,
      bool remember = false});

  /// 退出登录
  Future<void> logout();
}
