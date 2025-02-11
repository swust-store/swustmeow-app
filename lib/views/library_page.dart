import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/file.dart';
import 'package:swustmeow/utils/status.dart';

import '../components/utils/base_header.dart';
import '../components/utils/base_page.dart';
import '../data/m_theme.dart';
import '../services/value_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _isLoading = true;
  List<String> _dirs = [];
  List<String> _files = [];
  String? _currentDir;
  String? _isDownloading;
  List<String> _downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    _load();
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
      if (!mounted) return;
      showErrorToast(context, '获取资料库失败：${dataResult.value}');
      return;
    }

    final dirs = (dataResult.value as Map<String, dynamic>)['directories']
        as List<dynamic>;
    _refresh(() => _dirs = dirs.cast());
  }

  Future<void> _loadFiles(String dir) async {
    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    final dataResult = await service.listFiles(dir);
    if (dataResult.status != Status.ok) {
      if (!mounted) return;
      showErrorToast(context, '获取资料库失败：${dataResult.value}');
      return;
    }

    final files =
        (dataResult.value as Map<String, dynamic>)['files'] as List<dynamic>;
    List<String> fileNames = files.cast();
    List<String> downloaded = [];

    for (final fileName in fileNames) {
      if (await isFileExists(fileName)) {
        downloaded.add(fileName);
      }
    }

    _refresh(() {
      _files = fileNames;
      _downloadedFiles = downloaded;
    });
  }

  Future<void> _download(String dir, String file) async {
    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    final result = await service.downloadFile(dir, file);
    if (result.status != Status.ok) {
      if (!mounted) return;
      showErrorToast(context, '下载失败：${result.value}');
      return;
    }

    final bytes = result.value as List<int>;
    await saveFileLocally(file, bytes);
    _refresh(() {
      _downloadedFiles.add(file);
      _isDownloading = null;
    });
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: ValueService.isFlipEnabled.value,
      flipY: ValueService.isFlipEnabled.value,
      child: BasePage.gradient(
        headerPad: false,
        header: BaseHeader(
          title: Text(
            '资料库',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          suffixIcons: [
            IconButton(
              onPressed: () async {
                if (_isLoading) return;
                _refresh(() {
                  _isLoading = true;
                  _currentDir = null;
                });
                await _load();
              },
              icon: FaIcon(
                FontAwesomeIcons.rotateRight,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: PopScope(
            canPop: _currentDir == null,
            onPopInvokedWithResult: (didPop, __) {
              if (!didPop && _currentDir != null) {
                setState(() => _currentDir = null);
              }
            },
            child: _getContent(),
          ),
        ),
      ),
    );
  }

  Widget _getContent() {
    final bcStyle = TextStyle(fontWeight: FontWeight.w500);
    return Column(
      children: [
        FBreadcrumb(
          children: [
            FBreadcrumbItem(
              current: _currentDir == null,
              child: Text(
                '资料库',
                style: bcStyle,
              ),
            ),
            if (_currentDir != null)
              FBreadcrumbItem(
                current: _currentDir != null,
                child: Text(
                  _currentDir!,
                  style: bcStyle,
                ),
              )
          ],
        ),
        SizedBox(height: 4),
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: MTheme.primary2,
                  ),
                )
              : _buildList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 32),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final name = _currentDir == null ? _dirs[index] : _files[index];
        final downloaded = _downloadedFiles.contains(name);
        // final d = name.split('.');
        // final extension = _currentDir == null ? null : d.last;
        // final hasExt = _currentDir != null && extension != null;
        return _buildRow(name, downloaded);
      },
      separatorBuilder: (context, _) => Divider(),
      itemCount: _currentDir == null ? _dirs.length : _files.length,
    );
  }

  Widget _buildRow(String name, bool downloaded) {
    return FTappable(
      onPress: () async {
        if (_currentDir != null) return;
        setState(() {
          _currentDir = name;
          _isLoading = true;
        });
        await _loadFiles(name);
        setState(() => _isLoading = false);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, 4),
              child: FaIcon(
                _currentDir == null
                    ? FontAwesomeIcons.solidFolder
                    : FontAwesomeIcons.solidFile,
              ),
            ),
            SizedBox(width: 8.0),
            // if (hasExt) FBadge(label: Text(extension)),
            Expanded(
              child: AutoSizeText(
                name,
                // hasExt
                //     ? d.sublist(0, d.length - 1).join()
                //     : name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.0),
            if (_currentDir != null)
              _isDownloading == name
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: MTheme.primary2,
                        strokeWidth: 2,
                      ),
                    )
                  : Transform.translate(
                      offset: Offset(0, 4),
                      child: FTappable(
                        onPress: () async => await _onPress(name, downloaded),
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              FaIcon(
                                downloaded
                                    ? FontAwesomeIcons.arrowUpRightFromSquare
                                    : FontAwesomeIcons.download,
                              ),
                              Text(
                                downloaded ? '打开' : '下载',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPress(String name, bool downloaded) async {
    if (downloaded) {
      final result = await openFile(name);
      if (result || !context.mounted) {
        return;
      }

      if (!mounted) return;
      showErrorToast(context, '文件打开失败！');
      return;
    }

    if (_isDownloading != null) {
      showErrorToast(context, '不能同时下载多个文件');
      return;
    }
    _refresh(() => _isDownloading = name);
    await _download(_currentDir!, name);
  }
}
