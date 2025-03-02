import 'package:flutter/cupertino.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/entity/version/version_info.dart';

import '../entity/soa/course/course_entry.dart';
import '../entity/soa/course/courses_container.dart';

class ValueService {
  static ValueNotifier<bool> isFlipEnabled = ValueNotifier(false);
  static ValueNotifier<bool> isMeowEnabled = ValueNotifier(false);

  static ValueNotifier<bool> isCourseLoading = ValueNotifier(false);
  static bool cacheSuccess = false;
  static List<Activity> activities = [];
  static List<CoursesContainer> coursesContainers = [];
  static List<CoursesContainer> sharedContainers = [];
  static CoursesContainer? currentCoursesContainer;
  static List<CourseEntry> todayCourses = [];
  static CourseEntry? nextCourse;
  static CourseEntry? currentCourse;
  static bool needCheckCourses = true;
  static Map<String, List<dynamic>> customCourses = {};

  static String? currentGreeting;
  static String? currentAnnouncement;

  static List<VersionInfo>? versionInfoList;
  static bool checkedUpdate = false;
  static VersionInfo? latestVersion;
  static ValueNotifier<bool> hasUpdate = ValueNotifier(false);

  static ValueNotifier<double?> homeHeaderCourseCarouselCardHeight =
      ValueNotifier(null);

  static void clearCache() {
    activities = [];
    coursesContainers = [];
    currentCoursesContainer = null;
    todayCourses = [];
    nextCourse = null;
    currentCourse = null;
    needCheckCourses = true;
  }
}
