import 'package:hive/hive.dart';

class BoxService {
  static late Box activitiesBox;
  static late Box calendarBox;
  static late Box courseBox;
  static late Box todoBox;
  static late Box commonBox;
  static late Box soaBox;
  static Box? duifeneBox;

  static Future<void> open() async {
    activitiesBox = await Hive.openBox('activitiesBox');
    calendarBox = await Hive.openBox('calendarBox');
    courseBox = await Hive.openBox('courseBox');
    todoBox = await Hive.openBox('todoBox');
    commonBox = await Hive.openBox('commonBox');
    soaBox = await Hive.openBox('soaBox');
    duifeneBox = await Hive.openBox('duifeneBox');
  }

  static Future<void> clear() async {
    // final list = [activitiesBox, calendarBox, courseBox];
    // final list = [duifeneBox];
    final list = [courseBox];

    for (final box in list) {
      await box?.clear();
      await box?.deleteFromDisk();
    }

    // TODO 分离清理
  }
}
