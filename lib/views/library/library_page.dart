import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/icon_text_field.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/file.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/vibration_throttling_util.dart';

import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../data/m_theme.dart';
import '../../entity/library/directory_info.dart';
import '../../entity/library/file_info.dart';
import 'my_downloads_page.dart';
import 'upload_file_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _isLoading = true;
  List<DirectoryInfo> _directories = [];
  List<FileInfo> _files = [];
  String? _currentDir;
  String? _isDownloading;
  List<String> _downloadedFiles = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarShow = false;
  bool _isSearching = false;
  bool _isReallySearching = false;
  Map<String, List<FileInfo>> _searchResult = {};
  double _downloadProgress = 0.0;

  // 懒加载相关变量
  bool _isLoadingMore = false;
  bool _hasMoreFiles = true;
  final int _pageSize = 20;
  int _currentPage = 1;

  // 缓存常用组件
  Widget? _cachedDownloadsEntry;
  Widget? _cachedUploadEntry;

  // 添加列表项缓存
  final Map<String, Widget> _fileItemCache = {};
  final Map<String, Widget> _dirItemCache = {};

  // 缓存常用颜色和样式
  final TextStyle _titleStyle = const TextStyle(
    fontSize: 14,
    color: Color(0xFF2C3E50),
    fontWeight: FontWeight.w500,
  );

  final TextStyle _subtitleStyle = const TextStyle(
    fontSize: 12,
    color: Color(0xFF95A5A6),
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 预加载常用图标和样式
    precacheFileIcons();
  }

  Future<void> _load() async {
    await _loadDirs();
    _refresh(() => _isLoading = false);
  }

  Future<void> _loadDirs() async {
    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    final dataResult = await service.getDirectories();
    if (dataResult.status != Status.ok) {
      showErrorToast('获取资料库失败：${dataResult.value}');
      return;
    }

    // 从响应中提取 directories 字段
    Map<String, dynamic> resultData = dataResult.value as Map<String, dynamic>;
    List<DirectoryInfo> directoryList =
        (resultData['directories'] as List).cast<DirectoryInfo>();

    _refresh(() => _directories = directoryList);
  }

  Future<void> _loadFiles(String dir, {bool reset = true}) async {
    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    if (reset) {
      _currentPage = 1;
      _hasMoreFiles = true;
      _files = [];
      _downloadedFiles = [];
    } else if (!_hasMoreFiles) {
      return;
    }

    _isLoadingMore = true;

    final dataResult = await service.listFiles(
      dir,
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (dataResult.status != Status.ok) {
      showErrorToast('获取资料库失败：${dataResult.value}');
      _isLoadingMore = false;
      return;
    }

    Map<String, dynamic> resultData = dataResult.value as Map<String, dynamic>;
    List<FileInfo> fileInfos = (resultData['files'] as List).cast<FileInfo>();

    int totalPages = resultData['total_pages'] as int;
    _hasMoreFiles = _currentPage < totalPages;

    if (_hasMoreFiles) {
      _currentPage++;
    }

    List<String> downloaded = List.from(_downloadedFiles);

    // 检查哪些文件已下载
    for (final file in fileInfos) {
      if (await isFileExists(dir, file.name)) {
        downloaded.add(file.name);
      }
    }

    _refresh(() {
      _files = reset ? fileInfos : [..._files, ...fileInfos];
      _downloadedFiles = downloaded;
      _isLoadingMore = false;
      _isLoading = false;
    });
  }

  Future<void> _download(FileInfo file) async {
    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    final result = await service.downloadFile(
      file.uuid,
      onProgress: (count, total) {
        if (total != null) {
          setState(() {
            _downloadProgress = count / total;
          });
        }
      },
    );

    if (result.status != Status.ok) {
      showErrorToast('下载失败：${result.value}');
      return;
    }

    final bytes = result.value as List<int>;
    await saveFileLocally(_currentDir, file.name, bytes);
    _refresh(() {
      _downloadedFiles.add(file.name);
      _isDownloading = null;
      _downloadProgress = 0.0;
    });
  }

  Future<void> _getSearchResult(String query) async {
    if (!_isSearching) return;

    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    final result = await service.searchFiles(query);
    if (result.status != Status.ok) {
      showErrorToast('搜索失败：${result.value}');
      return;
    }

    _refresh(() => _searchResult = result.value as Map<String, List<FileInfo>>);
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      headerPad: false,
      header: BaseHeader(
        title: '资料库',
        suffixIcons: [
          IconButton(
            onPressed: () {
              _refresh(() => _isSearchBarShow = !_isSearchBarShow);
            },
            icon: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: MTheme.backgroundText,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (_isLoading) return;
              _refresh(() => _isLoading = true);

              if (_currentDir == null) {
                await _load();
              } else {
                await _loadFiles(_currentDir!);
                _refresh(() => _isLoading = false);
              }
            },
            icon: FaIcon(
              FontAwesomeIcons.rotateRight,
              color: MTheme.backgroundText,
              size: 20,
            ),
          ),
        ],
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: PopScope(
          canPop: _currentDir == null && !_isSearching,
          onPopInvokedWithResult: (didPop, __) {
            if (!didPop && (_currentDir != null || _isSearching)) {
              setState(() {
                _currentDir = null;
                _isSearching = false;
                _isReallySearching = false;
                _searchController.clear();
              });
            }
          },
          child: _getContent(),
        ),
      ),
    );
  }

  Widget _getContent() {
    return Column(
      children: [
        if (_isSearchBarShow) ...[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: IconTextField(
              controller: _searchController,
              autofocus: true,
              maxLines: 1,
              hint: '搜索文件...',
              icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
              onChange: (value) {
                if (value.isContentEmpty) {
                  setState(() {
                    _isReallySearching = false;
                    _isSearching = false;
                    _searchResult = {};
                  });
                  return;
                }

                _refresh(() => _isSearching = true);
                VibrationThrottlingUtil.debounce(
                  () {
                    _refresh(() => _isReallySearching = true);
                    _getSearchResult(value);
                  },
                  300,
                );
              },
            ),
          ),
          SizedBox(height: 16),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.house,
                size: 14,
                color: Color(0xFF95A5A6),
              ),
              SizedBox(width: 8),
              FTappable(
                onPress: _currentDir != null
                    ? () => setState(() => _currentDir = null)
                    : null,
                child: Text(
                  '根目录',
                  style: TextStyle(
                    fontSize: 13,
                    color: _currentDir != null
                        ? MTheme.primary2
                        : Color(0xFF34495E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_currentDir != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    FontAwesomeIcons.angleRight,
                    size: 12,
                    color: Color(0xFF95A5A6),
                  ),
                ),
                Text(
                  _currentDir!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF34495E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              Spacer(),
            ],
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: MTheme.primary2,
                  ),
                )
              : _isReallySearching
                  ? _buildSearchResultList()
                  : _buildList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore &&
            _hasMoreFiles &&
            _currentDir != null &&
            scrollInfo.metrics.pixels >
                scrollInfo.metrics.maxScrollExtent - 200) {
          _loadFiles(_currentDir!, reset: false);
        }
        return false;
      },
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 32),
        itemCount: _currentDir == null
            ? _directories.length + 1 // 根目录：目录数量 + "我的下载"入口
            : _files.length +
                (_hasMoreFiles ? 2 : 1), // 子目录：文件数量 + "上传文件"入口 + 加载指示器(如果有更多)
        itemBuilder: (context, index) {
          if (index == 0) {
            if (_currentDir == null) {
              return _cachedDownloadsEntry ??= _buildDownloadsEntry();
            } else {
              return _cachedUploadEntry ??= _buildUploadEntry();
            }
          }

          if (_currentDir == null) {
            if (index <= _directories.length) {
              final dir = _directories[index - 1];
              return _dirItemCache[dir.name] ??= _buildDirectoryItem(dir);
            }
            return const SizedBox.shrink();
          } else {
            if (index - 1 < _files.length) {
              final file = _files[index - 1];
              final key = "${_currentDir}_${file.name}";
              final downloaded = _downloadedFiles.contains(file.name);

              // 如果文件项有状态变化（如下载状态），则重建
              if (_isDownloading == file.name ||
                  !_fileItemCache.containsKey(key)) {
                _fileItemCache[key] = _buildListItem(file, downloaded);
              }
              return _fileItemCache[key]!;
            } else if (_hasMoreFiles) {
              // 显示加载更多指示器
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MTheme.primary2,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }
        },
        separatorBuilder: (context, index) {
          // 最后一个加载指示器前不需要分隔线
          if (_currentDir != null && _hasMoreFiles && index == _files.length) {
            return const SizedBox.shrink();
          }
          return const Divider(color: Color(0x1A000000), height: 1);
        },
      ),
    );
  }

  Widget _buildDownloadsEntry() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          pushTo(context, '/library/my_downloads', const MyDownloadsPage());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: Icon(
                  FontAwesomeIcons.download,
                  size: 22,
                  color: MTheme.primary2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('我的下载', style: _titleStyle),
                    const SizedBox(height: 4),
                    Text('查看已下载的文件', style: _subtitleStyle),
                  ],
                ),
              ),
              const Icon(
                FontAwesomeIcons.angleRight,
                size: 16,
                color: Color(0xFF95A5A6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectoryItem(DirectoryInfo dir) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          setState(() {
            _currentDir = dir.name;
            _isLoading = true;
          });
          await _loadFiles(dir.name);
          setState(() => _isLoading = false);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: Icon(
                  FontAwesomeIcons.solidFolder,
                  size: 26,
                  color: Color(0xFFF39C12),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dir.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${dir.fileCount} 个文件',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.angleRight,
                size: 16,
                color: Color(0xFF95A5A6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadEntry() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          pushTo(
            context,
            '/library/upload',
            UploadFilePage(directory: _currentDir!),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: Icon(
                  FontAwesomeIcons.fileCirclePlus,
                  size: 22,
                  color: MTheme.primary2,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '上传文件',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '点击上传新文件到当前目录',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.angleRight,
                size: 16,
                color: Color(0xFF95A5A6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(FileInfo file, bool downloaded) {
    final extension = file.name.split('.').last.toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (downloaded) {
            final result = await openFile(_currentDir, file.name);
            if (!result) {
              showErrorToast('文件打开失败！');
            }
          } else {
            if (_isDownloading != null) {
              showErrorToast('不能同时下载多个文件');
              return;
            }
            _refresh(() => _isDownloading = file.name);
            await _download(file);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: Icon(
                  _getFileIcon(extension),
                  size: 22,
                  color: _getIconColor(extension),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$extension ${formatFileSize(file.size)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                  ],
                ),
              ),
              _buildFileActions(file, downloaded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileActions(FileInfo file, bool downloaded) {
    if (_isDownloading == file.name) {
      return Container(
        width: 40,
        height: 40,
        padding: EdgeInsets.all(4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: _downloadProgress,
              color: MTheme.primary2,
              strokeWidth: 2,
            ),
            Text(
              '${(_downloadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                color: MTheme.primary2,
              ),
            ),
          ],
        ),
      );
    }

    if (downloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              final result = await openFile(_currentDir, file.name);
              if (!result) {
                showErrorToast('文件打开失败！');
              }
            },
            icon: Icon(
              FontAwesomeIcons.arrowUpRightFromSquare,
              size: 16,
              color: MTheme.primary2,
            ),
            tooltip: '打开',
          ),
          IconButton(
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => FDialog(
                  direction: Axis.horizontal,
                  title: Text('确认删除'),
                  body: Text('确定要删除文件"${file.name}"吗？'),
                  actions: [
                    FButton(
                      onPress: () => Navigator.of(context).pop(false),
                      label: Text('取消'),
                      style: FButtonStyle.secondary,
                    ),
                    FButton(
                      onPress: () => Navigator.of(context).pop(true),
                      label: Text('删除'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _deleteFile(file.name);
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
      );
    }

    return IconButton(
      onPressed: () async {
        if (_isDownloading != null) {
          showErrorToast('不能同时下载多个文件');
          return;
        }
        _refresh(() => _isDownloading = file.name);
        await _download(file);
      },
      icon: Icon(
        FontAwesomeIcons.download,
        size: 16,
        color: MTheme.primary2,
      ),
      tooltip: '下载',
    );
  }

  Widget _buildSearchResultList() {
    if (!_isSearching) return _buildList();

    final dirs = _searchResult.keys.toList();
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 32),
      itemCount: dirs.length,
      itemBuilder: (context, i) {
        final dir = dirs[i];
        final files = _searchResult[dir]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                dir,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withValues(alpha: 0.9),
                ),
              ),
            ),
            ...files.map((file) {
              final downloaded = _downloadedFiles.contains(file.name);
              return _buildListItem(file, downloaded);
            }),
            Divider(color: Colors.black.withValues(alpha: 0.1)),
          ],
        );
      },
    );
  }

  IconData _getFileIcon(String extension) {
    final ext = extension.toLowerCase();
    if (_fileIconCache.containsKey(ext)) {
      return _fileIconCache[ext]!;
    }

    IconData icon;
    switch (ext) {
      case 'pdf':
        icon = FontAwesomeIcons.filePdf;
        break;
      case 'doc':
      case 'docx':
        icon = FontAwesomeIcons.fileWord;
        break;
      case 'xls':
      case 'xlsx':
        icon = FontAwesomeIcons.fileExcel;
        break;
      case 'ppt':
      case 'pptx':
        icon = FontAwesomeIcons.filePowerpoint;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        icon = FontAwesomeIcons.fileImage;
        break;
      case 'zip':
      case '7z':
      case 'rar':
        icon = FontAwesomeIcons.fileZipper;
        break;
      default:
        icon = FontAwesomeIcons.file;
    }

    _fileIconCache[ext] = icon;
    return icon;
  }

  Color _getIconColor(String? extension) {
    if (extension == null) return Color(0xFFF39C12);

    final ext = extension.toLowerCase();
    if (_fileColorCache.containsKey(ext)) {
      return _fileColorCache[ext]!;
    }

    Color color;
    switch (ext) {
      case 'pdf':
        color = Color(0xFFE74C3C);
        break;
      case 'doc':
      case 'docx':
        color = Color(0xFF3498DB);
        break;
      case 'xls':
      case 'xlsx':
        color = Color(0xFF2ECC71);
        break;
      case 'ppt':
      case 'pptx':
        color = Color(0xFFE67E22);
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        color = Color(0xFF9B59B6);
        break;
      case 'zip':
      case '7z':
      case 'rar':
        color = Color(0x88964500);
        break;
      default:
        color = Color(0xFF95A5A6);
    }

    _fileColorCache[ext] = color;
    return color;
  }

  Future<void> _deleteFile(String name) async {
    final String dirPath = await getDownloadDirectory();
    final String filePath = '$dirPath/$name';
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      _refresh(() {
        _downloadedFiles.remove(name);
      });
    }
  }

  // 文件图标缓存
  final Map<String, IconData> _fileIconCache = {};
  final Map<String, Color> _fileColorCache = {};

  void precacheFileIcons() {
    // 预缓存常用文件类型图标
    final commonTypes = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'jpg',
      'png',
      'zip'
    ];
    for (final type in commonTypes) {
      _fileIconCache[type] = _getFileIcon(type);
      _fileColorCache[type] = _getIconColor(type);
    }
  }
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
