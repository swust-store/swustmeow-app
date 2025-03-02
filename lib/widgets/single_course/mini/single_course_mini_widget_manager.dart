import 'dart:async';
import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/widgets/entities/single_course.dart';
import 'package:swustmeow/widgets/single_course/mini/single_course_mini_widget_state.dart';

import '../../../utils/courses.dart';

class SingleCourseMiniWidgetManager {
  final state = SingleCourseMiniWidgetState();

  SingleCourseMiniWidgetManager() {
    updateState();
    updateWidget();
    Timer.periodic(const Duration(seconds: 30), (_) async {
      updateState();
      await updateWidget();
    });
  }

  void updateState() {
    final now = DateTime.now();
    state.lastUpdateTimestamp.value = now.millisecondsSinceEpoch;
    final currentContainer =
        ValueService.currentCoursesContainer?.withCustomCourses;
    final entries = currentContainer?.entries;

    if (currentContainer == null || entries == null) {
      state.success.value = false;
      state.clear();
      return;
    }

    final currentTerm = currentContainer.term;
    final (_, current, next) = getCourse(currentTerm, entries);
    state.success.value = true;

    final (_, week) = getWeekNum(currentTerm, now);
    state.weekNum.value = week;

    final (currentTime, _) =
        current == null ? (null, null) : getCourseRemainingString(current);
    state.current.value = current == null
        ? null
        : SingleCourse(
            name: current.courseName,
            place: current.place,
            time: currentTime!,
            color: current.color.toString(),
          );

    final (nextTime, nextDiff) =
        next == null ? (null, null) : getCourseRemainingString(next);
    state.next.value = next == null
        ? null
        : SingleCourse(
            name: next.courseName,
            place: next.place,
            time: nextTime!,
            diff: nextDiff!,
            color: next.color.toString(),
          );
  }

  Future<void> updateWidget() async {
    await HomeWidget.saveWidgetData(
        'singleCourseMiniSuccess', state.success.value);
    await HomeWidget.saveWidgetData(
        'singleCourseMiniLastUpdateTimestamp', state.lastUpdateTimestamp.value);
    await HomeWidget.saveWidgetData(
        'singleCourseMiniCurrent', json.encode(state.current.value?.toJson()));
    await HomeWidget.saveWidgetData(
        'singleCourseMiniNext', json.encode(state.next.value?.toJson()));
    await HomeWidget.saveWidgetData(
        'singleCourseMiniWeekNum', state.weekNum.value);

    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'store.swust.swustmeow.widgets.single_course.mini.SingleCourseMiniWidgetReceiver',
    );
  }
}
