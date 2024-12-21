import 'package:hive/hive.dart';

class BoxService {
  static late Box calendarEventListBox;
  static late Box courseEntryListBox;
  static late Box todoListBox;

  static Future<void> open() async {
    calendarEventListBox = await Hive.openBox('calendarEventListBox');
    courseEntryListBox = await Hive.openBox('courseEntryListBox');
    todoListBox = await Hive.openBox('todoListBox');
  }

  static Future<void> clear() async {
    final list = [calendarEventListBox, courseEntryListBox, todoListBox];

    for (final box in list) {
      await box.clear();
      await box.deleteFromDisk();
    }
  }
}
