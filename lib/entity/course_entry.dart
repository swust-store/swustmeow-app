import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miaomiaoswust/data/values.dart';
import 'package:miaomiaoswust/utils/time.dart';

part 'course_entry.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class CourseEntry {
  CourseEntry(
      {required this.courseName,
      required this.teacherName,
      required this.startWeek,
      required this.endWeek,
      required this.place,
      required this.weekday,
      required this.numberOfDay,
      this.color = 0xFF000000});

  @HiveField(0)
  final String courseName;

  @HiveField(1)
  final List<String> teacherName;

  @HiveField(2)
  final int startWeek;

  @HiveField(3)
  final int endWeek;

  @HiveField(4)
  final String place;

  @HiveField(5)
  final int weekday;

  @HiveField(6)
  final int numberOfDay;

  @HiveField(7)
  int color;

  factory CourseEntry.fromJson(Map<String, dynamic> json) =>
      _$CourseEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CourseEntryToJson(this);

  // TODO 优化 让所有课程根据名称集合为一个对象 避免分散
  List<CourseEntry> _findSameCourses(List<CourseEntry> entries) =>
      entries.where((e) => e.courseName == courseName).toList()
        ..sort((a, b) => b.weekday.compareTo(a.weekday));

  bool checkIfFinished(List<CourseEntry> entries) {
    final now = Values.now;
    final week = getCourseWeekNum(now);
    final weekday = now.weekday;

    final lastCourse = _findSameCourses(entries).firstOrNull ?? this;
    final time = Values.courseTableTimes[lastCourse.numberOfDay - 1];

    if (week != endWeek) return week > endWeek;
    if (weekday != lastCourse.weekday) return weekday > lastCourse.weekday;
    return hmAfter('${now.hour}:${now.minute}', time.split('\n').last);
  }

  int getWeeksRemaining(List<CourseEntry> entries) {
    final lastCourse = _findSameCourses(entries).firstOrNull ?? this;
    final now = Values.now;
    final base = (lastCourse.endWeek - getCourseWeekNum(now)).abs();
    if (now.weekday < lastCourse.weekday) return base + 1;
    if (now.weekday > lastCourse.weekday) return base;

    final time = Values.courseTableTimes[lastCourse.numberOfDay - 1];
    return hmAfter('${now.hour}:${now.minute}', time.split('\n').last)
        ? base
        : base + 1;
  }
}
