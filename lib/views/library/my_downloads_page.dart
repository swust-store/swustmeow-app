import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/utils/file.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../utils/common.dart';
import 'library_page.dart';

class MyDownloadsPage extends StatefulWidget {
  const MyDownloadsPage({super.key});

  @override
  State<MyDownloadsPage> createState() => _MyDownloadsPageState();
}

class _MyDownloadsPageState extends State<MyDownloadsPage> {
  Map<String, List<FileSystemEntity>> _groupedFiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final String rootPath = await getDownloadDirectory();
    final Directory rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }

    // 获取所有子目录
    final List<Directory> dirs = await rootDir
        .list()
        .where((entity) => entity is Directory)
        .map((entity) => entity as Directory)
        .toList();

    // 获取根目录下的文件
    final List<File> rootFiles = await rootDir
        .list()
        .where((entity) => entity is File)
        .map((entity) => entity as File)
        .toList();

    Map<String, List<FileSystemEntity>> grouped = {};

    // 添加根目录文件
    if (rootFiles.isNotEmpty) {
      grouped['未分类'] = rootFiles;
    }

    // 添加各个目录下的文件
    for (var dir in dirs) {
      final dirName = dir.path.split('/').last;
      final files = await dir.list().where((entity) => entity is File).toList();
      if (files.isNotEmpty) {
        grouped[dirName] = files;
      }
    }

    setState(() {
      _groupedFiles = grouped;
      _isLoading = false;
    });
  }

  Future<void> _deleteFile(String dirName, String fileName) async {
    final String path = dirName == '未分类'
        ? await getDownloadDirectory()
        : await getDirectoryPath(dirName);
    final String filePath = '$path/$fileName';
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        _groupedFiles[dirName]?.removeWhere((f) => f.path == filePath);
        if (_groupedFiles[dirName]?.isEmpty == true) {
          _groupedFiles.remove(dirName);
        }
      });
    }
  }

  Color _getIconColor(String? extension) {
    if (extension == null) return Color(0xFFF39C12);

    switch (extension.toLowerCase()) {
      case 'pdf':
        return Color(0xFFE74C3C);
      case 'doc':
      case 'docx':
        return Color(0xFF3498DB);
      case 'xls':
      case 'xlsx':
        return Color(0xFF2ECC71);
      case 'ppt':
      case 'pptx':
        return Color(0xFFE67E22);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Color(0xFF9B59B6);
      case 'zip':
      case '7z':
      case 'rar':
        return Color(0x88964500);
      default:
        return Color(0xFF95A5A6);
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'ppt':
      case 'pptx':
        return FontAwesomeIcons.filePowerpoint;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return FontAwesomeIcons.fileImage;
      case 'zip':
      case '7z':
      case 'rar':
        return FontAwesomeIcons.fileZipper;
      default:
        return FontAwesomeIcons.file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(
        title: '我的下载',
        suffixIcons: [
          IconButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadFiles();
            },
            icon: FaIcon(
              FontAwesomeIcons.rotateRight,
              color: MTheme.backgroundText,
              size: 20,
            ),
          ),
        ],
      ),
      content: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: MTheme.primary2,
        ),
      )
          : _groupedFiles.isEmpty
          ? Center(
        child: Text(
          '暂无下载文件',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _groupedFiles.length,
        itemBuilder: (context, i) {
          final dirName = _groupedFiles.keys.elementAt(i);
          final files = _groupedFiles[dirName]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  dirName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withValues(alpha: 0.9),
                  ),
                ),
              ),
              ...files.map((file) {
                final fileName = file.path.split('/').last;
                final extension =
                fileName.split('.').last.toUpperCase();
                final fileSize = File(file.path).lengthSync();

                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final result = await openFile(
                            dirName == '未分类' ? null : dirName,
                            fileName,
                          );
                          if (!result) {
                            showErrorToast('文件打开失败！');
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: _getIconColor(extension)
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getFileIcon(extension),
                                  size: 18,
                                  color: _getIconColor(extension),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fileName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2C3E50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '$extension ${formatFileSize(fileSize)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF95A5A6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final result = await openFile(
                                        dirName == '未分类'
                                            ? null
                                            : dirName,
                                        fileName,
                                      );
                                      if (!result) {
                                        showErrorToast('文件打开失败！');
                                      }
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons
                                          .arrowUpRightFromSquare,
                                      size: 16,
                                      color: MTheme.primary2,
                                    ),
                                    tooltip: '打开',
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final bool? confirm =
                                      await showDialog<bool>(
                                        context: context,
                                        builder: (context) =>
                                            FDialog(
                                              direction:
                                              Axis.horizontal,
                                              title: Text('确认删除'),
                                              body: Text(
                                                  '确定要删除文件"$fileName"吗？'),
                                              actions: [
                                                FButton(
                                                  onPress: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(false),
                                                  label: Text('取消'),
                                                  style: FButtonStyle
                                                      .secondary,
                                                ),
                                                FButton(
                                                  onPress: () =>
                                                      Navigator.of(
                                                          context)
                                                          .pop(true),
                                                  label: Text('删除'),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm == true) {
                                        await _deleteFile(
                                            dirName, fileName);
                                        showSuccessToast('文件已删除');
                                      }
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.trash,
                                      size: 16,
                                      color: Colors.red[300],
                                    ),
                                    tooltip: '删除',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.black.withValues(alpha: 0.1),
                      height: 1,
                    ),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
