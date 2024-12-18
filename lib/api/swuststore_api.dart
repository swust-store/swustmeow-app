import '../entity/course_entry.dart';
import '../utils/api.dart';
import '../utils/status.dart';

/// 登录到一站式系统并获取凭证 (TGC)
Future<StatusContainer<String>> apiLogin(
    String username, String password) async {
  try {
    final response = await getBackendApiResponse('POST', '/api/s/login',
        data: {'username': username, 'password': password});
    if (response == null || response.code != 200) {
      return StatusContainer(Status.fail, response?.message);
    }
    return StatusContainer(Status.ok, response.data as String);
  } on Exception catch (e) {
    return StatusContainer(Status.fail, '内部错误：${e.toString()}');
  }
}

/// 根据登录凭证 (TGC) 获取普通课表
Future<StatusContainer<dynamic>> getCourseTable(String tgc) async {
  final response = await getBackendApiResponse('GET', '/api/s/get_course_table',
      queryParameters: {'TGC': tgc});
  if (response == null || response.code != 200 || response.data == null) {
    return StatusContainer(
        response?.code == 401 ? Status.notAuthorized : Status.fail,
        response?.message);
  }

  final List<CourseEntry> entries = [];
  for (final Map<String, dynamic> entry in response.data!) {
    final entity = CourseEntry.fromJson(entry);
    entries.add(entity);
  }
  return StatusContainer(Status.ok, entries);
}
