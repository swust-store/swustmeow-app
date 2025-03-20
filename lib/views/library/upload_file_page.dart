import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/components/utils/base_header.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/status.dart';

import '../../utils/common.dart';

class UploadFilePage extends StatefulWidget {
  final String directory;

  const UploadFilePage({
    super.key,
    required this.directory,
  });

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  static const Set<String> _allowedExtensions = {
    // 文档
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt',
    // 压缩文件
    'zip', 'rar', '7z',
  };
  static const int _maxFileSize = 30 * 1024 * 1024; // 30MB in bytes

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions.toList(),
    );

    if (result != null) {
      final file = result.files.single;

      // 检查文件大小
      if (file.size > _maxFileSize) {
        showErrorToast('文件大小不能超过30MB');
        return;
      }

      setState(() {
        _selectedFilePath = file.path;
        _selectedFileName = file.name;
      });
    }
  }

  String get _allowedExtensionsText {
    final docs = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'];
    final compress = ['zip', 'rar', '7z'];

    return '支持的文件类型：\n'
        '文档：${docs.join(', ')}\n'
        '压缩包：${compress.join(', ')}';
  }

  Future<void> _uploadFile() async {
    if (_selectedFilePath == null) {
      showErrorToast('请先选择文件');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    final result = await service.uploadFile(
      _selectedFilePath!,
      widget.directory,
      onProgress: (count, total) {
        setState(() {
          _uploadProgress = count / total;
        });
      },
    );

    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
    });

    if (result.status == Status.ok) {
      showSuccessToast('上传成功');
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      showErrorToast('上传失败：${result.value}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(title: '上传文件'),
      content: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.folderOpen,
                    size: 14,
                    color: Color(0xFF95A5A6),
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.directory,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF34495E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MTheme.primary2.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MTheme.primary2.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.circleInfo,
                        size: 14,
                        color: MTheme.primary2,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '上传须知',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: MTheme.primary2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _allowedExtensionsText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF34495E),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '文件大小限制：30MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF34495E),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '注意：上传的文件经过审核后才会公开展示',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF34495E),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 14,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '严禁上传任何违法违规、侵权或有害内容，造成不良影响的违规者将承担相应法律责任！',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: _isUploading ? null : _pickFile,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DottedBorder(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedFilePath == null
                              ? FontAwesomeIcons.fileCirclePlus
                              : FontAwesomeIcons.fileLines,
                          size: 48,
                          color: MTheme.primary2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _selectedFileName ?? '点击选择文件',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF34495E),
                          ),
                        ),
                        if (_selectedFilePath != null) ...[
                          SizedBox(height: 8),
                          Text(
                            '点击重新选择',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF95A5A6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(MTheme.primary2),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '上传中 ${(_uploadProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF95A5A6),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              onPressed: _isUploading || _selectedFilePath == null
                  ? null
                  : _uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: MTheme.primary2,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isUploading ? '上传中...' : '开始上传',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
