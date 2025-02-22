import 'package:flutter/cupertino.dart';
import 'package:swustmeow/widgets/single_course/single_course.dart';

class SingleCourseWidgetState {
  final success = ValueNotifier(true);
  final lastUpdateTimestamp = ValueNotifier(DateTime.now().millisecondsSinceEpoch);
  final current = ValueNotifier<SingleCourse?>(null);
  final next = ValueNotifier<SingleCourse?>(null);

  void clear() {
    current.value = null;
    next.value = null;
  }
}
