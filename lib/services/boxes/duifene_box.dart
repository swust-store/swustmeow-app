import 'package:hive/hive.dart';

class DuiFenEBox {
  static late Box _box;

  static Future<void> open() async {
    _box = await Hive.openBox('duifeneBox');
  }

  static T? get<T>(String key) => _box.get(key) as T?;

  static Future<void> put(String key, dynamic value) => _box.put(key, value);

  static Future<void> clearCache() async {}
}
