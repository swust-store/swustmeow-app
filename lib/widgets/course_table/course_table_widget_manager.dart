import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/widgets/course_table/course_table_widget_state.dart';

import '../../components/course_table/course_table.dart';
import '../../services/value_service.dart';

class CourseTableWidgetManager {
  final state = CourseTableWidgetState();

  CourseTableWidgetManager() {
    _refresh();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _refresh();
      if (GlobalService.mediaQueryData != null) {
        timer.cancel();
      }
    });
  }

  Future<void> _refresh() async {
    await updateState();
    await updateWidget();
  }

  Future<void> updateState() async {
    final currentContainer =
        ValueService.currentCoursesContainer?.withCustomCourses;

    if (currentContainer == null || GlobalService.mediaQueryData == null) {
      return;
    }

    final now = DateTime.now();
    state.lastUpdateTimestamp.value = now.millisecondsSinceEpoch;
    state.success.value = true;

    final mq = GlobalService.mediaQueryData!;
    final size = mq.size;
    final path = await HomeWidget.renderFlutterWidget(
      MediaQuery(
        data: GlobalService.mediaQueryData!,
        child: CourseTable(
          container: currentContainer,
          isLoading: false,
          pageWidth: size.width,
          pageHeight: size.height,
          timeColumnWidth: 34,
        ),
      ),
      key: 'courseTableImage',
      logicalSize: size,
      pixelRatio: mq.devicePixelRatio,
    );
    state.imagePath.value = path;
  }

  Future<void> updateWidget() async {
    await HomeWidget.saveWidgetData('courseTableSuccess', state.success.value);
    await HomeWidget.saveWidgetData(
        'courseTableLastUpdateTimestamp', state.lastUpdateTimestamp.value);
    await HomeWidget.saveWidgetData(
        'courseTableImagePath', state.imagePath.value);

    await HomeWidget.updateWidget(
      qualifiedAndroidName:
          'store.swust.swustmeow.widgets.course_table.CourseTableWidgetReceiver',
    );
  }
}
