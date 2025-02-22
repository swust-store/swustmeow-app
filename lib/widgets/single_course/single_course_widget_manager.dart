import 'dart:async';
import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/widgets/single_course/single_course.dart';
import 'package:swustmeow/widgets/single_course/single_course_widget_state.dart';

import '../../utils/courses.dart';

class SingleCourseWidgetManager {
  final state = SingleCourseWidgetState();

  SingleCourseWidgetManager() {
    updateState();
    state.lastUpdateTimestamp.value = DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(const Duration(seconds: 5), (_) async {
      updateState();
      updateWidget();
    });
  }

  void updateState() {
    final currentContainer = ValueService.currentCoursesContainer;
    final entries = currentContainer?.entries;
    if (currentContainer == null || entries == null) {
      state.success.value = false;
      state.clear();
      return;
    }

    final (_, current, next) = getCourse(currentContainer, entries);
    if (current != null || next != null) {
      state.success.value = true;
    }

    if (current != null) {
      final (time, _) = getCourseRemainingString(current);
      state.current.value = SingleCourse(
        name: current.courseName,
        place: current.place,
        time: time,
      );
    }
    if (next != null) {
      final (time, diff) = getCourseRemainingString(next);
      state.next.value = SingleCourse(
        name: next.courseName,
        place: next.place,
        time: time,
        diff: diff,
      );
    }
  }

  Future<void> updateWidget() async {
    await HomeWidget.saveWidgetData('singleCourseSuccess', state.success.value);
    await HomeWidget.saveWidgetData(
        'lastUpdateTimestamp', state.lastUpdateTimestamp.value);
    await HomeWidget.saveWidgetData(
        'singleCourseCurrent', json.encode(state.current.value?.toJson()));
    await HomeWidget.saveWidgetData(
        'singleCourseNext', json.encode(state.next.value?.toJson()));

    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'store.swust.swustmeow.widgets.single_course.SingleCourseWidgetReceiver',
    );
  }
}
