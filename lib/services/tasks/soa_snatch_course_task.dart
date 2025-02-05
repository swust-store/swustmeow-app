import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:swustmeow/entity/soa/soa_snatch_course_status.dart';
import 'package:swustmeow/services/tasks/background_task.dart';
import 'package:swustmeow/services/tasks/notification_manager.dart';

class SOASnatchCourseTask extends BackgroundTask {
  static const _name = '一站式抢课';
  static final _notificationManager =
      NotificationManager(name: _name, notificationId: 14866459);
  static SOASnatchCourseStatus _status = SOASnatchCourseStatus.initializing;

  SOASnatchCourseTask()
      : super(name: _name, duration: const Duration(seconds: 1)) {
    _notificationManager.configureNotification();
  }

  @override
  Future<bool> get shouldAutoStart async => false;

  Future<void> _changeStatus(
      ServiceInstance service, SOASnatchCourseStatus status,
      {String? courseName}) async {
    _status = status;
    await invoke(service, 'soaSnatchCourseStatus', {
      'status': status.toString(),
      'courseName': courseName,
    });
  }

  @override
  Future<void> run(ServiceInstance service, bool enableNotification)async {

  }

  @override
  Future<void> stop(ServiceInstance service, bool enableNotification) async {
    _notificationManager.showNotification(
        enabled: enableNotification, content: '已停止');
    await _changeStatus(service, SOASnatchCourseStatus.stopped);
  }
}
