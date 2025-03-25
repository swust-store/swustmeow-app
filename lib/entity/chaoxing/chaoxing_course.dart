class ChaoXingCourse {
  final String courseName;
  final String teacherName;
  final int courseId;
  final int classId;
  final int cpi;

  const ChaoXingCourse({
    required this.courseName,
    required this.teacherName,
    required this.courseId,
    required this.classId,
    required this.cpi,
  });

  @override
  String toString() {
    return 'ChaoXingCourse(teacherName: $teacherName, courseName: $courseName, courseId: $courseId, classId: $classId, cpi: $cpi)';
  }
}
