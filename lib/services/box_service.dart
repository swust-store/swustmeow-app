import 'package:hive/hive.dart';

class BoxService {
  static late Box calendarEventListBox;
  static late Box courseEntryListBox;

  static Future<void> open() async {
    calendarEventListBox = await Hive.openBox('calendarEventListBox');
    courseEntryListBox = await Hive.openBox('courseEntryListBox');
  }

  static Future<void> clear() async {
    await calendarEventListBox.deleteFromDisk();
    await courseEntryListBox.deleteFromDisk();
  }
}
