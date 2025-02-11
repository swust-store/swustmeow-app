import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/services/global_service.dart';
import 'package:swustmeow/utils/common.dart';
import 'package:swustmeow/utils/file.dart';
import 'package:swustmeow/utils/status.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:swustmeow/utils/vibration_throttling_util.dart';

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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarShow = false;
  bool _isSearching = false;
  bool _isReallySearching = false;
  Map<String, List<String>> _searchResult = {};

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

  Future<void> _getSearchResult(String query) async {
    if (!_isSearching) return;

    final service = GlobalService.fileServerApiService;
    if (service == null) return;

    final result = await service.searchFiles(query);
    if (result.status != Status.ok) {
      if (!mounted) return;
      showErrorToast(context, '搜索失败：${result.value}');
      return;
    }

    final data = result.value as Map<String, dynamic>;
    final map = data['results'] as Map<String, dynamic>;
    Map<String, List<String>> searchResult = {};
    for (final key in map.keys) {
      List<String> entries = (map[key]! as List<dynamic>).cast();
      searchResult[key] = entries;
      for (final entry in entries) {
        if (!_downloadedFiles.contains(entry) && await isFileExists(entry)) {
          _downloadedFiles.add(entry);
        }
      }
    }

    _refresh(() => _searchResult = searchResult);
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
              onPressed: () {
                _refresh(() => _isSearchBarShow = !_isSearchBarShow);
              },
              icon: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: Colors.white,
                size: 20,
              ),
            ),
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
        if (_isSearchBarShow) ...[
          SizedBox(height: 6),
          FTextField(
            controller: _searchController,
            autofocus: true,
            maxLines: 1,
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
        ],
        SizedBox(height: 4),
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

  Widget _buildSearchResultList() {
    if (!_isSearching) return _buildList();
    final dirs = _searchResult.keys.toList();
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 32),
      shrinkWrap: true,
      itemBuilder: (context, i) {
        final dir = dirs[i];
        final files = _searchResult[dir]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow(dir, false, isDir: true),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: 16),
              itemBuilder: (context, j) {
                final name = files[j];
                final downloaded = _downloadedFiles.contains(name);
                return _buildRow(name, downloaded, isDir: false, dir: dir);
              },
              separatorBuilder: (context, _) => Divider(),
              itemCount: files.length,
            ),
          ],
        );
      },
      separatorBuilder: (context, _) => Divider(),
      itemCount: dirs.length,
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

  Widget _buildRow(String name, bool downloaded, {bool? isDir, String? dir}) {
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
                isDir ?? _currentDir == null
                    ? isDir ?? false
                        ? FontAwesomeIcons.folderOpen
                        : FontAwesomeIcons.solidFolder
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
            if (_currentDir != null || (isDir != null && !isDir))
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
                        onPress: () async => await _onPress(name, downloaded,
                            isDir: isDir, dir: dir),
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

  Future<void> _onPress(String name, bool downloaded,
      {bool? isDir, String? dir}) async {
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

    if (isDir == null || dir == null) {
      await _download(_currentDir!, name);
    } else {
      await _download(dir, name);
    }
  }
}
