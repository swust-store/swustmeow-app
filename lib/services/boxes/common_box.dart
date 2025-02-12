import 'package:hive/hive.dart';
import 'package:swustmeow/services/global_service.dart';

class CommonBox {
  static late Box _box;

  static Future<void> open() async {
    _box = await Hive.openBox('commonBox');
  }

  static T? get<T>(String key) => _box.get(key) as T?;

  static Future<void> put(String key, dynamic value) => _box.put(key, value);

  static Future<void> delete(String key) => _box.delete(key);

  static Future<void> clearCache() async {
    final keys = ['hitokoto', 'serverInfo'];
    for (final key in keys) {
      await delete(key);
    }
  }
}
