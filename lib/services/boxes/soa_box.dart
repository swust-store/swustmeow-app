import 'package:hive/hive.dart';

class SOABox {
  static late Box _box;

  static Future<void> open() async {
    _box = await Hive.openBox('soaBox');
  }

  static T? get<T>(String key) => _box.get(key) as T?;

  static Future<void> put(String key, dynamic value) => _box.put(key, value);

  static Future<void> delete(String key) => _box.delete(key);

  static Future<void> clearCache() async {
    final keys = [
      'optionalCourses',
      'examSchedules',
      'courseScores',
      'pointsData'
    ];
    for (final key in keys) {
      await delete(key);
    }
  }
}
