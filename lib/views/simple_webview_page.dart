import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/base_webview.dart';
import '../components/utils/base_header.dart';
import '../components/utils/base_page.dart';
import '../services/value_service.dart';

class SimpleWebViewPage extends StatefulWidget {
  const SimpleWebViewPage({
    super.key,
    required this.initialUrl,
    this.title,
  });

  final String initialUrl;
  final String? title;

  @override
  State<StatefulWidget> createState() => _SimpleWebViewPageState();
}

class _SimpleWebViewPageState extends State<SimpleWebViewPage> {
  String? _title;
  InAppWebViewController? _controller;
  bool _isLoading = true;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
  }

  @override
  void dispose() {
    if (_controller != null && !_disposed) {
      _controller?.dispose();
      _controller = null;
    }
    super.dispose();
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
      child: BasePage.color(
        roundedBorder: false,
        headerPad: false,
        header: BaseHeader(
          title: AutoSizeText(
            widget.title != null ? widget.title! : _title ?? '网页',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
            maxLines: 1,
            minFontSize: 6,
            overflow: TextOverflow.ellipsis,
          ),
          suffixIcons: [
            IconButton(
              onPressed: () async {
                if (_disposed) return;
                await _controller?.reload();
              },
              icon: FaIcon(
                FontAwesomeIcons.rotateRight,
                color: Colors.white,
                size: 20,
              ),
            )
          ],
        ),
        content: BaseWebView(
          url: widget.initialUrl,
          onLoadStop: (_, __) => _refresh(() => _isLoading = false),
          onDispose: () => _disposed = true,
          onTitleChanged: (_, title) {
            if (title == null) return;
            _refresh(() => _title = title);
          },
        ),
      ),
    );
  }
}
