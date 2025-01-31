import 'package:miaomiaoswust/entity/duifene/duifene_course.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_test_base.dart';

class DuiFenETest extends DuiFenETestBase {
  const DuiFenETest(
      {required this.course,
      required super.name,
      required this.createTime,
      required super.beginTime,
      required super.endTime,
      required this.submitTime,
      required this.limitMinutes,
      required this.creatorName,
      required this.score,
      required super.finished,
      required this.overdue});

  final DuiFenECourse course;
  final DateTime createTime;
  final DateTime? submitTime;
  final int limitMinutes;
  final String creatorName;
  final int score;
  final bool overdue;
}
