import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:swustmeow/data/values.dart';

import '../../components/base_webview.dart';
import '../../components/utils/base_header.dart';
import '../../components/utils/base_page.dart';
import '../../services/value_service.dart';

class SOAYKTPage extends StatefulWidget {
  const SOAYKTPage({super.key});

  @override
  State<StatefulWidget> createState() => _SOAYKTPageState();
}

class _SOAYKTPageState extends State<SOAYKTPage> {
  static const _url = 'http://ykt.swust.edu.cn/plat/shouyeUser';
  InAppWebViewController? _controller;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
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
          title: Text(
            '一卡通',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        content: ValueListenableBuilder(
          valueListenable: Values.isDarkMode,
          builder: (context, isDarkMode, child) {
            return Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: BaseWebView(
                  url: _url,
                  onLoadStart: (controller, _) =>
                      _refresh(() => _controller = controller),
                  onDispose: () => _disposed = true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
