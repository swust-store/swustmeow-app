import 'package:hive/hive.dart';

class ActivitiesBox {
  static late Box _box;

  static Future<void> open() async {
    _box = await Hive.openBox('activitiesBox');
  }

  static T? get<T>(String key) => _box.get(key) as T?;

  static Future<void> put(String key, dynamic value) => _box.put(key, value);

  static Future<void> clearCache() async {
    if (!_box.isOpen) return;
    await _box.clear();
    await _box.deleteFromDisk();
  }
}
