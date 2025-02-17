import 'package:hive/hive.dart';

class CourseBox {
  static late Box _box;

  static Future<void> open() async {
    _box = await Hive.openBox('courseBox');
  }

  static T? get<T>(String key) {
    if (!_box.isOpen) return null;
    return _box.get(key) as T?;
  }

  static Future<void> put(String key, dynamic value) async {
    if (!_box.isOpen) return;
    await _box.put(key, value);
  }

  static Future<void> delete(String key) async {
    if (!_box.isOpen) return;
    await _box.delete(key);
  }

  static Future<void> clearCache() async {
    if (!_box.isOpen) return;
    await _box.clear();
    await _box.deleteFromDisk();
  }
}
