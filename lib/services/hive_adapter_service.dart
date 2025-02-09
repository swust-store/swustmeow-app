import 'package:hive/hive.dart';
import 'package:swustmeow/entity/activity.dart';
import 'package:swustmeow/entity/activity_type.dart';
import 'package:swustmeow/entity/calendar_event.dart';
import 'package:swustmeow/entity/course/course_entry.dart';
import 'package:swustmeow/entity/course/course_type.dart';
import 'package:swustmeow/entity/course/courses_container.dart';
import 'package:swustmeow/entity/course/term_date.dart';
import 'package:swustmeow/entity/duifene/duifene_course.dart';
import 'package:swustmeow/entity/duifene/duifene_sign_mode.dart';
import 'package:swustmeow/entity/run_mode.dart';
import 'package:swustmeow/entity/server_info.dart';
import 'package:swustmeow/entity/soa/leave/daily_leave_options.dart';
import 'package:swustmeow/entity/soa/leave/leave_type.dart';
import 'package:swustmeow/entity/soa/leave/vehicle_type.dart';
import 'package:swustmeow/entity/soa/optional_course.dart';
import 'package:swustmeow/entity/soa/optional_course_type.dart';
import 'package:swustmeow/entity/soa/optional_task_type.dart';
import 'package:swustmeow/entity/todo.dart';

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
    Hive.registerAdapter<CourseType>(CourseTypeAdapter());
    Hive.registerAdapter<CoursesContainer>(CoursesContainerAdapter());
    Hive.registerAdapter<TermDate>(TermDateAdapter());
    Hive.registerAdapter<OptionalCourse>(OptionalCourseAdapter());
    Hive.registerAdapter<OptionalCourseType>(OptionalCourseTypeAdapter());
    Hive.registerAdapter<OptionalTaskType>(OptionalTaskTypeAdapter());
    Hive.registerAdapter<DailyLeaveOptions>(DailyLeaveOptionsAdapter());
    Hive.registerAdapter<VehicleType>(VehicleTypeAdapter());
    Hive.registerAdapter<LeaveType>(LeaveTypeAdapter());
  }
}
