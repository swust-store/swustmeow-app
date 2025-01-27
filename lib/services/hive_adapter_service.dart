import 'package:hive/hive.dart';
import 'package:miaomiaoswust/entity/activity.dart';
import 'package:miaomiaoswust/entity/activity_type.dart';
import 'package:miaomiaoswust/entity/calendar_event.dart';
import 'package:miaomiaoswust/entity/course_entry.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_course.dart';
import 'package:miaomiaoswust/entity/duifene/duifene_sign_mode.dart';
import 'package:miaomiaoswust/entity/run_mode.dart';
import 'package:miaomiaoswust/entity/server_info.dart';
import 'package:miaomiaoswust/entity/todo.dart';

class HiveAdapterService {
  void register() {
    Hive.registerAdapter<ServerInfo>(ServerInfoAdapter());
    Hive.registerAdapter<ActivityType>(ActivityTypeAdapter());
    Hive.registerAdapter<Activity>(ActivityAdapter());
    Hive.registerAdapter<CalendarEvent>(CalendarEventAdapter());
    Hive.registerAdapter<CourseEntry>(CourseEntryAdapter());
    Hive.registerAdapter<Todo>(TodoAdapter());
    Hive.registerAdapter<DuiFenECourse>(DuiFenECourseAdapter());
    Hive.registerAdapter<DuiFenESignMode>(DuiFenESignModeAdapter());
    Hive.registerAdapter<RunMode>(RunModeAdapter());
  }
}
