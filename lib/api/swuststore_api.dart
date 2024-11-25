import 'package:miaomiaoswust/entity/course_table_entity.dart';
import 'package:miaomiaoswust/entity/course_table_entry_entity.dart';
import 'package:miaomiaoswust/utils/api.dart';
import 'package:miaomiaoswust/utils/status.dart';

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
  final response =
      await getBackendApiResponse('GET', '/api/s/get_course_table');
  if (response == null || response.code != 200 || response.data == null) {
    return StatusContainer(Status.fail, response?.message);
  }

  final List<CourseTableEntryEntity> entries = List.empty();
  for (final entry in response.data! as List<Map<String, dynamic>>) {
    final entity = CourseTableEntryEntity.fromJson(entry);
    entries.add(entity);
  }

  final courseTable = CourseTableEntity(entries: entries, experiments: []);
  return StatusContainer(Status.ok, courseTable);
}
