import 'package:miaomiaoswust/entity/course_entry.dart';
import 'package:miaomiaoswust/services/box_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/swuststore_api.dart';
import 'status.dart';

Future<StatusContainer<String>> performLogin(
    String? username, String? password) async {
  final prefs = await SharedPreferences.getInstance();
  if (username == null || password == null) {
    username = prefs.getString('username');
    password = prefs.getString('password');
  }

  if (username == null || password == null) {
    return const StatusContainer(Status.fail, '内部参数错误');
  }

  final loginResult = await apiLogin(username, password);

  if (loginResult.status == Status.fail) {
    return loginResult;
  }

  final tgc = loginResult.value!;
  await prefs.setBool('isLogin', true);
  await prefs.setString('TGC', tgc);
  await prefs.setString('username', username);
  await prefs.setString('password', password);
  final isFirstTime = prefs.getBool('isFirstTime');
  if (isFirstTime ?? true) {
    await prefs.setBool('isFirstTime', false);
  }
  return StatusContainer(Status.ok, tgc);
}

Future<StatusContainer<dynamic>> getCourseEntries() async {
  final prefs = await SharedPreferences.getInstance();
  final tgc = prefs.getString('TGC');
  if (tgc == null) return const StatusContainer(Status.notAuthorized, '未登录');
  final result = await getCourseTable(tgc);
  if (result.status != Status.ok) return result;
  final r = result.value as List<CourseEntry>;
  await BoxService.courseEntryListBox.put('courseTableEntries', r);
  return StatusContainer(Status.ok, r);
}
