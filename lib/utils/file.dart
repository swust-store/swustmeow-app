import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart' as sys_paths;
import 'package:permission_handler/permission_handler.dart';

import 'status.dart';

Future<bool> checkStoragePermission() async {
  final plugin = DeviceInfoPlugin();
  final androidInfo = await plugin.androidInfo;
  final storageStatus = androidInfo.version.sdkInt < 33
      ? await Permission.storage.request()
      : PermissionStatus.granted;

  switch (storageStatus) {
    case PermissionStatus.granted:
      return true;
    case PermissionStatus.denied:
      return false;
    case PermissionStatus.permanentlyDenied:
      openAppSettings();
      return false;
    default:
      return false;
  }
}

Future<StatusContainer<File?>> saveToTempDir(
    Uint8List bytes, String filename) async {
  if (!await checkStoragePermission()) {
    return const StatusContainer(Status.permissionRequired);
  }
  var appDir = (await sys_paths.getExternalStorageDirectory())!;
  final file = File('${appDir.path}/$filename');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
  return StatusContainer(Status.ok, file);
}
