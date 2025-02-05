import 'package:hive/hive.dart';
import 'package:swustmeow/entity/course/course_entry.dart';
import 'package:swustmeow/entity/course/course_type.dart';

part 'courses_container.g.dart';

@HiveType(typeId: 10)
class CoursesContainer {
  const CoursesContainer(
      {required this.type, required this.term, required this.entries});

  /// 课程表类型，详见 [CourseType]
  @HiveField(0)
  final CourseType type;

  /// 课程表学期字符串
  ///
  /// 格式为：开始学年-结束学年-上/下，
  /// 如：2024-2025-上
  @HiveField(1)
  final String term;

  /// 课程表课程列表
  @HiveField(2)
  final List<CourseEntry> entries;
}
