import 'dart:convert';

import 'package:miaomiaoswust/entity/course_table_entity.dart';
import 'package:miaomiaoswust/entity/course_table_entry_entity.dart';
import 'package:miaomiaoswust/entity/response_entity.dart';
import 'package:miaomiaoswust/utils/api.dart';
import 'package:miaomiaoswust/utils/status.dart';

/// 登录到一站式系统并获取凭证 (TGC)
Future<StatusContainer<String>> apiLogin(
    String username, String password) async {
  try {
    final response = await getBackendApiResponse('POST', '/s/api/login');
    final resp = ResponseEntity<String>.fromJson(jsonDecode(response.data));
    if (resp.code != 200) return StatusContainer(Status.fail, resp.message);
    return StatusContainer(Status.ok, resp.data);
  } on Exception catch (e) {
    return const StatusContainer(Status.fail, '内部错误');
  }
}

/// 根据登录凭证 (TGC) 获取普通课表
Future<StatusContainer<dynamic>> getCourseTable(String tgc) async {
  final response =
      await getBackendApiResponse('GET', '/s/api/get_course_table');
  final resp = ResponseEntity<List<Map<String, dynamic>>>.fromJson(
      jsonDecode(response.data));
  if (resp.code != 200 || resp.data == null) {
    return StatusContainer(Status.fail, resp.message);
  }

  final List<CourseTableEntryEntity> entries = List.empty();
  for (final entry in resp.data!) {
    final entity = CourseTableEntryEntity.fromJson(entry);
    entries.add(entity);
  }

  final courseTable = CourseTableEntity(entries: entries, experiments: []);
  return StatusContainer(Status.ok, courseTable);
}
