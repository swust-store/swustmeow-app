import 'package:hive/hive.dart';

part 'course_score.g.dart';

@HiveType(typeId: 20)
class CourseScore {
  const CourseScore({
    required this.courseName,
    required this.courseId,
    required this.credit,
    required this.courseType,
    required this.formalScore,
    required this.resitScore,
    required this.points,
  });

  @HiveField(0)
  final String courseName;
  @HiveField(1)
  final String courseId;
  @HiveField(2)
  final double credit;
  @HiveField(3)
  final String courseType; // 必修/任选...
  @HiveField(4)
  final String formalScore;
  @HiveField(5)
  final String resitScore;
  @HiveField(6)
  final double points;
}
