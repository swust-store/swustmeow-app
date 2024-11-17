import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class Constants {
  const Constants(this.context);

  final BuildContext context;

  EdgeInsetsGeometry get padding => context.theme.style.pagePadding * 2;

  String get instruction =>
      "「喵喵西科」是一个非官方的课表、校历、考试等各类信息的聚合 APP，旨在为西科大学子提供一个易用、简单、舒适的校园一站式服务平台。";

  ImageProvider get loginBgImage =>
      const AssetImage('assets/images/login_bg.jpg');
}
