import 'package:flutter/material.dart';
import 'package:swustmeow/services/account/account_service.dart';

/// (名字，图标，图标颜色，构造器，归属的 [AccountService] 获取器，是否展示在主页)
typedef ToolEntry = (
  String,
  IconData,
  Color,
  dynamic Function(),
  AccountService? Function(),
  bool
);
