import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/values.dart';

class NotificationService {
  static late AndroidNotificationChannel androidChannel;

  NotificationService() {
    androidChannel = AndroidNotificationChannel(
        Values.notificationChannelId, '${Values.name} - 后台服务',
        importance: Importance.max);
  }

  Future<void> init() async {
    final plugin = FlutterLocalNotificationsPlugin();

    // TODO 完善 IOS 版本，配置图标
    await plugin.initialize(InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')));

    final androidImpl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    androidImpl?.createNotificationChannel(androidChannel);
    // TODO 完善权限系统
    androidImpl?.requestNotificationsPermission();
  }

  Future<void> show(
      {int? id,
      String? title,
      String? body,
      Importance? importance,
      Priority? priority}) async {
    final plugin = FlutterLocalNotificationsPlugin();

    plugin.show(
        id ?? Values.notificationId,
        title,
        body,
        NotificationDetails(
            android: AndroidNotificationDetails(
                androidChannel.id, androidChannel.name,
                ongoing: false)));
  }
}
