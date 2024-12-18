import 'package:hive/hive.dart';
import 'package:miaomiaoswust/entity/calendar_event.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';

class HiveAdapterService {
  void register() {
    Hive.registerAdapter<CalendarEvent>(CalendarEventAdapter());
    Hive.registerAdapter<CourseEntry>(CourseEntryAdapter());
  }
}
