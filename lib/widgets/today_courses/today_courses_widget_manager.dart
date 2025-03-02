import 'dart:async';
import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:swustmeow/widgets/entities/single_course.dart';
import 'package:swustmeow/widgets/today_courses/today_courses_widget_state.dart';

import '../../services/value_service.dart';
import '../../utils/courses.dart';

class TodayCoursesWidgetManager {
  final state = TodayCoursesWidgetState();

  TodayCoursesWidgetManager() {
    updateState();
    updateWidget();
  }

  void updateState() {
    final now = DateTime.now();
    state.lastUpdateTimestamp.value = now.millisecondsSinceEpoch;
    final currentContainer =
        ValueService.currentCoursesContainer?.withCustomCourses;

    if (currentContainer == null) {
      state.success.value = false;
      state.clear();
      return;
    }

    final currentTerm = currentContainer.term;
    final (todayCourses, _, _) =
        getCourse(currentTerm, currentContainer.entries);

    state.success.value = true;

    final (_, week) = getWeekNum(currentTerm, now);
    state.weekNum.value = week;
    state.todayCourses.value = todayCourses.map((entry) {
      final (time, _) = getCourseRemainingString(entry);
      return SingleCourse(
        name: entry.displayName != entry.courseName
            ? '${entry.displayName} - ${entry.courseName}'
            : entry.courseName,
        place: entry.place,
        time: time,
        color: entry.color.toString(),
      );
    }).toList();
  }

  Future<void> updateWidget() async {
    await HomeWidget.saveWidgetData('todayCoursesSuccess', state.success.value);
    await HomeWidget.saveWidgetData(
        'todayCoursesLastUpdateTimestamp', state.lastUpdateTimestamp.value);
    await HomeWidget.saveWidgetData('todayCoursesList',
        json.encode(state.todayCourses.value?.map((c) => c.toJson()).toList()));
    await HomeWidget.saveWidgetData('todayCoursesWeekNum', state.weekNum.value);

    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'store.swust.swustmeow.widgets.today_courses.TodayCoursesWidgetReceiver',
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'store.swust.swustmeow.widgets.today_courses.mini.TodayCoursesMiniWidgetReceiver',
    );
  }
}
