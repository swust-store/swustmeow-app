import 'package:flutter/cupertino.dart';

class CourseTableWidgetState {
  final success = ValueNotifier(true);
  final lastUpdateTimestamp =
      ValueNotifier(DateTime.now().millisecondsSinceEpoch);
  final imagePath = ValueNotifier<String?>(null);

  void clear() {
    imagePath.value = null;
  }
}
