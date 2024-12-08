import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miaomiaoswust/core/server_info.dart';
import 'package:miaomiaoswust/entity/course_table_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final entityJson = json.decode(entityJsonString) as Map<String, dynamic>;
    return CourseTableEntity.fromJson(entityJson);
  }

  static DateTime get now => DateTime.now();

  static List<Map<String, dynamic>> get timeGreetings => [
        {
          'time': '05:00-10:59',
          'greetings': [
            '早上好',
            'Good Morning☀️',
            '元气满满新的一天🤩',
            '清晨阳光灿烂✨',
            '新的一天新气象🌟',
            '早起的鸟儿有虫吃🐦'
          ]
        },
        {
          'time': '11:00-12:59',
          'greetings': ['中午好', '今天也要吃饱饱🥰', '午饭时间到🍔', '想好吃什么了吗😋']
        },
        {
          'time': '13:00-16:59',
          'greetings': ['下午好', '来点小甜品🍰', '学习加油哦💪']
        },
        {
          'time': '17:00-22:59',
          'greetings': ['晚上好', '夜幕降临✨']
        },
        {
          'time': '23:00-04:59',
          'greetings': [
            '夜深了',
            '明天见😊',
            '睡个好觉做个美梦🌙',
            '夜猫子还在忙碌吗💻',
            '愿你有个宁静的夜晚💫'
          ]
        }
      ];
}
