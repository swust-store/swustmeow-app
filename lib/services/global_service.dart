import 'package:miaomiaoswust/api/hitokoto_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalService {
  static Future<void> load() async {
    await _loadHitokoto();
  }

  static Future<void> _loadHitokoto() async {
    final hitokoto = await getHitokoto();
    final prefs = await SharedPreferences.getInstance();
    final string = hitokoto.value?.hitokoto;
    if (string != null) {
      await prefs.setString('hitokoto', string);
    }
  }
}
