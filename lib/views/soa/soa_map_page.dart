import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:forui/forui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swustmeow/components/base_webview.dart';
import 'package:swustmeow/services/permission_service.dart';
import 'package:swustmeow/utils/common.dart';

import '../../data/values.dart';

class SOAMapPage extends StatefulWidget {
  const SOAMapPage({super.key});

  @override
  State<StatefulWidget> createState() => _SOAMapPageState();
}

class _SOAMapPageState extends State<SOAMapPage> {
  InAppWebViewController? _controller;
  final _checkInterval = Duration(milliseconds: 100);
  bool _isLoading = true;
  bool _disposed = false;

  static const _url = 'https://gis.swust.edu.cn/#/home?campus=78924';
  final _ops =
      '''document.querySelector('body > app-root > div.layer-operations')''';
  final _header =
      '''document.querySelector('body > app-root > app-home > app-header > div')''';
  final _searchPanel =
      '''document.querySelector('body > app-root > app-home > app-search > div.search-panel')''';
  final _searchResult =
      '''document.querySelector('body > app-root > app-home > app-search > div.search-result')''';

  bool _operationsFound = false;
  bool _headerFound = false;
  bool _searchPanelFound = false;
  bool _searchResultFound = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status =
        await PermissionService.requestPermission(Permission.location);
    if (status != PermissionStatus.granted) {
      if (!mounted) return;
      showErrorToast(context, '无定位权限，地图部分功能可能不可用');
    }
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
      flipX: Values.isFlipEnabled.value,
      flipY: Values.isFlipEnabled.value,
      child: FScaffold(
        contentPad: false,
        header: FHeader.nested(
          title: const Text(
            '校园地图',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          prefixActions: [
            FHeaderAction(
                icon: FIcon(FAssets.icons.chevronLeft),
                onPress: () => Navigator.of(context).pop())
          ],
          suffixActions: [
            FHeaderAction(
                icon: FIcon(
                  FAssets.icons.search,
                  color: _isLoading ? Colors.grey : null,
                ),
                onPress: () async {
                  if (_isLoading) return;
                  await _onSearch();
                }),
            FHeaderAction(
                icon: FIcon(
                  FAssets.icons.rotateCw,
                  color: _isLoading ? Colors.grey : null,
                ),
                onPress: () async {
                  if (_isLoading || _disposed) return;
                  _refresh(() {
                    _operationsFound = false;
                    _headerFound = false;
                    _searchPanelFound = false;
                    _searchResultFound = false;
                  });
                  await _controller?.reload();
                })
          ],
        ),
        content: BaseWebView(
          url: _url,
          onLoadStart: (controller, _) async {
            _controller = controller;
            await Future.doWhile(_changeOperationsPosition);
            await Future.doWhile(_removeHeader);
            await Future.doWhile(_changeSearchPosition);
            await Future.doWhile(_changeSearchResultSize);
          },
          onLoadStop: (_, __) => _refresh(() => _isLoading = false),
          onDispose: () => _disposed = true,
        ),
      ),
    );
  }

  Future<void> _onSearch() async {
    if (!_searchPanelFound || _controller == null || _disposed) return;

    await _controller!.evaluateJavascript(source: '''
      var search = $_searchPanel;
      var ops = $_ops;
      var tag = 'active';
      var active = search.classList.contains(tag);
      if (active) {
        ops.style.top = '0.3rem';
        search.classList.remove(tag);
      } else {
        ops.style.top = '1.3rem';
        search.classList.add(tag);
      }
    ''');
  }

  Future<bool> _changeOperationsPosition() async {
    if (_controller == null) return true;
    if (_operationsFound) return false;
    await Future.delayed(_checkInterval);

    if (_disposed) return false;
    bool result =
        await _controller!.evaluateJavascript(source: '$_ops !== null');
    if (result) {
      _operationsFound = true;
      await _controller!
          .evaluateJavascript(source: '''$_ops.style.top = '0.3rem';''');
      return false;
    }
    return true;
  }

  Future<bool> _removeHeader() async {
    if (_controller == null) return true;
    if (_headerFound) return false;
    await Future.delayed(_checkInterval);

    if (_disposed) return false;
    bool result =
        await _controller!.evaluateJavascript(source: '$_header !== null');
    if (result) {
      _headerFound = true;
      await _controller!
          .evaluateJavascript(source: '''$_header.style.display = 'none';''');
      return false;
    }
    return true;
  }

  Future<bool> _changeSearchPosition() async {
    if (_controller == null) return true;
    if (_searchPanelFound) return false;
    await Future.delayed(_checkInterval);

    if (_disposed) return false;
    bool result =
        await _controller!.evaluateJavascript(source: '$_searchPanel !== null');
    if (result) {
      _searchPanelFound = true;
      await _controller!.evaluateJavascript(source: '''
        var search = $_searchPanel;
        
        var box = search.querySelector('div.search-box');
        box.style.paddingLeft = '0px';
        var icon = box.querySelector('div.search-return');
        icon.style.display = 'none';
        
        var recommend = search.querySelector('div.search-recommend');
        recommend.style.boxShadow = '0 0px 0px white';
      ''');
      return false;
    }
    return true;
  }

  Future<bool> _changeSearchResultSize() async {
    if (_controller == null) return true;
    if (_searchResultFound) return false;
    await Future.delayed(_checkInterval);

    if (_disposed) return false;
    bool result = await _controller!
        .evaluateJavascript(source: '$_searchResult !== null');
    if (result) {
      _searchResultFound = true;
      await _controller!.evaluateJavascript(source: '''
        var result = $_searchResult;
        result.style.minHeight = '2.4rem';
        
        var total = result.querySelector('div.total-search-result');
        total.style.height = '1.2rem';
        total.style.alignContent = 'center';
      ''');
      return false;
    }
    return true;
  }
}
