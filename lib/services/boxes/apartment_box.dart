import 'package:hive/hive.dart';

class ApartmentBox {
  static late Box _box;

  static Future<void> open() async {
    _box = await Hive.openBox('apartmentBox');
  }

  static T? get<T>(String key) => _box.get(key) as T?;

  static Future<void> put(String key, dynamic value) => _box.put(key, value);

  static Future<void> delete(String key) => _box.delete(key);

  static Future<void> clearCache() async {
    final keys = ['studentInfo'];
    for (final key in keys) {
      await delete(key);
    }
  }
}
