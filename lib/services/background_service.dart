import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// TODO 为 IOS 配置 `flutter_background_service`
class BackgroundService {
  static final List<Function(ServiceInstance service)> _callbacks = [];

  Future<void> init() async {
    final service = FlutterBackgroundService();
    await service.configure(
        androidConfiguration:
            AndroidConfiguration(onStart: _onStart, isForegroundMode: true),
        iosConfiguration: IosConfiguration(
            onForeground: _onStart, onBackground: _onIosBackground));
    await start();
  }

  void register(Function(ServiceInstance service) callback) =>
      _callbacks.add(callback);

  Future<bool> start() async {
    final service = FlutterBackgroundService();
    return await service.startService();
  }

  void stop() {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }

  @pragma('vm:entry-point') // 动态调用，防止树摇优化
  static Future<void> _onStart(ServiceInstance service) async {
    debugPrint('开始后台服务...');

    service.on('start').listen((event) => debugPrint('后台服务开始运行：$event'));
    service.on('stop').listen((event) {
      service.stopSelf();
      debugPrint('后台服务结束运行：$event');
    });

    for (final callback in _callbacks) {
      callback(service);
    }
  }

  @pragma('vm:entry-point')
  Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    debugPrint('IOS 切换为后台');
    return true;
  }
}
