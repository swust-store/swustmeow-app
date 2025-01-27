import 'package:miaomiaoswust/entity/duifene/duifene_course.dart';

class DuiFenETest {
  const DuiFenETest(
      {required this.course,
      required this.name,
      required this.createTime,
      required this.beginTime,
      required this.endTime,
      required this.submitTime,
      required this.limitMinutes,
      required this.creatorName,
      required this.score,
      required this.finished,
      required this.overdue});

  final DuiFenECourse course;
  final String name;
  final DateTime createTime;
  final DateTime beginTime;
  final DateTime endTime;
  final DateTime? submitTime;
  final int limitMinutes;
  final String creatorName;
  final int score;
  final bool finished;
  final bool overdue;
}
