import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/swuststore_api.dart';
import '../entity/course_entry.dart';
import '../utils/status.dart';
import 'box_service.dart';

class SOAService {
  ValueNotifier<bool> isLogin = ValueNotifier(false);

  /// 登录到一站式系统并获取凭证 (TGC)
  ///
  /// 若登录成功，返回包含 `TGC` 字符串的状态容器；
  /// 否则，返回包含错误信息字符串的状态容器。
  Future<StatusContainer<String>> login(
      String? username, String? password) async {
    final prefs = await SharedPreferences.getInstance();
    if (username == null || password == null) {
      username = prefs.getString('soaUsername');
      password = prefs.getString('soaPassword');
    }

    if (username == null || password == null) {
      return const StatusContainer(Status.fail, '内部参数错误');
    }

    final loginResult = await loginToSOA(username, password);

    if (loginResult.status == Status.fail) {
      return loginResult;
    }

    final tgc = loginResult.value!;
    isLogin.value = true;
    await prefs.setBool('isSOALogin', true);
    await prefs.setString('soaTGC', tgc);
    await prefs.setString('soaUsername', username);
    await prefs.setString('soaPassword', password);
    return StatusContainer(Status.ok, tgc);
  }

  /// 根据登录凭证（TGC）获取普通课表
  ///
  /// 若获取失败，返回包含错误信息字符串的状态容器；
  /// 否则，返回包含课程表的状态容器。
  Future<StatusContainer<dynamic>> getCourseEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final tgc = prefs.getString('soaTGC');
    if (tgc == null) return const StatusContainer(Status.notAuthorized, '未登录');
    final result = await getCourseTable(tgc);
    if (result.status != Status.ok) return result;
    List<CourseEntry> r = (result.value as List<dynamic>).cast();
    await BoxService.courseEntryListBox.put('courseTableEntries', r);
    return StatusContainer(Status.ok, r);
  }
}
