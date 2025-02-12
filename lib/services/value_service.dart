import 'package:flutter/cupertino.dart';
import 'package:swustmeow/entity/activity.dart';

import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/courses_container.dart';

class ValueService {
  static ValueNotifier<bool> isFlipEnabled = ValueNotifier(false);

  static List<Activity> activities = [];
  static List<CoursesContainer> coursesContainers = [];
  static CoursesContainer? currentCoursesContainer;
  static List<CourseEntry> todayCourses = [];
  static CourseEntry? nextCourse;
  static CourseEntry? currentCourse;
  static bool needCheckCourses = true;

  static String? currentGreeting;

  static String? currentAnnouncement;

  static void clearCache() {
    activities = [];
    coursesContainers = [];
    currentCoursesContainer = null;
    todayCourses = [];
    nextCourse = null;
    currentCourse = null;
    needCheckCourses = true;
    currentGreeting = null;
    currentAnnouncement = null;
  }
}
