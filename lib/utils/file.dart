import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

/// 获取应用的下载目录，此处使用应用文档目录下的 "downloads" 文件夹
Future<String> getDownloadDirectory() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final Directory downloadDir = Directory('${appDocDir.path}/downloads');
  if (!(await downloadDir.exists())) {
    await downloadDir.create(recursive: true);
  }
  return downloadDir.path;
}

/// 保存文件到本地
///
/// [fileName] 为文件名称（包含后缀），[bytes] 为下载后的二进制数据
///
/// 返回保存后的 [File] 对象
Future<File> saveFileLocally(String fileName, List<int> bytes) async {
  final String dirPath = await getDownloadDirectory();
  final String filePath = '$dirPath/$fileName';
  final File file = File(filePath);
  return await file.writeAsBytes(bytes, flush: true);
}

/// 检查本地是否已存在相同文件
///
/// [fileName] 为文件名称（包含后缀）
///
/// 返回 true 表示文件已存在，false 则不存在
Future<bool> isFileExists(String fileName) async {
  final String dirPath = await getDownloadDirectory();
  final String filePath = '$dirPath/$fileName';
  final File file = File(filePath);
  return await file.exists();
}

/// 打开本地文件
///
/// [fileName] 为文件名称（包含后缀）
///
/// 如果文件存在，则调用系统默认程序打开并返回 true；否则返回 false
Future<bool> openFile(String fileName) async {
  final String dirPath = await getDownloadDirectory();
  final String filePath = '$dirPath/$fileName';
  final File file = File(filePath);
  if (await file.exists()) {
    await OpenFile.open(filePath);
    return true;
  } else {
    return false;
  }
}
