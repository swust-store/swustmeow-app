import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miaomiaoswust/core/server_info.dart';
import 'package:miaomiaoswust/entity/course_table_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entity/course_table_entry_entity.dart';

class Values {
  static String get instruction =>
      '「喵喵西科」是一个非官方的课表、校历、考试等各类信息的聚合 APP，旨在为西科大学子提供一个易用、简单、舒适的校园一站式服务平台。';

  static String get agreementPrompt =>
      '为了更好地保障您的合法权益，并为您提供更好的使用体验，请您阅读并同意协议以继续使用「喵喵西科」。';

  static ImageProvider get loginBgImage =>
      const AssetImage('assets/images/login_bg.jpg');

  static ImageProvider get catLoadingGif =>
      const AssetImage('assets/images/dancing_kitty_black.gif');

  static List<String> get courseTableTimes => [
        '08:00\n09:40',
        '10:00\n11:40',
        '14:00\n15:40',
        '16:00\n17:40',
        '19:00\n20:40',
        '20:40\n22:40'
      ];

  static String get fetchInfoUrl => 'http://110.40.79.230:90/static/info.json';

  static Future<ServerInfo> get serverInfo async => ServerInfo.fetch();

  static TextStyle get dialogButtonTextStyle =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  static ThemeMode? themeMode;

  static Future<CourseTableEntity?> get cachedCourseTableEntity async {
    final prefs = await SharedPreferences.getInstance();
    final entityJsonString = prefs.getString('courseTableEntity');
    if (entityJsonString == null) return null;
    final entityJson = json.decode(entityJsonString) as Map<String,dynamic>;
    return CourseTableEntity.fromJson(entityJson);
  }
}
