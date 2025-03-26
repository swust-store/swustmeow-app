import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:swustmeow/data/m_theme.dart';

class BaseWebView extends StatefulWidget {
  const BaseWebView({
    super.key,
    required this.url,
    this.onLoadStart,
    this.onLoadStop,
    this.onUpdateVisitedHistory,
    this.onTitleChanged,
    this.onDispose,
  });

  final String url;
  final Function(InAppWebViewController controller, WebUri? url)? onLoadStart;
  final Function(InAppWebViewController controller, WebUri? url)? onLoadStop;
  final Function(
          InAppWebViewController controller, WebUri? url, bool? isReload)?
      onUpdateVisitedHistory;
  final Function(InAppWebViewController controller, String? title)?
      onTitleChanged;
  final Function()? onDispose;

  @override
  State<StatefulWidget> createState() => _BaseWebViewState();
}

class _BaseWebViewState extends State<BaseWebView> {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: MTheme.primary2),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                _webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                _webViewController?.loadUrl(
                  urlRequest:
                      URLRequest(url: await _webViewController?.getUrl()),
                );
              }
            },
          );
  }

  @override
  void dispose() {
    _webViewController?.dispose();

    if (widget.onDispose != null) {
      widget.onDispose!();
    }

    // _pullToRefreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            geolocationEnabled: true,
            sharedCookiesEnabled: true,
          ),
          pullToRefreshController: _pullToRefreshController,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onLoadStart: (controller, url) {
            if (widget.onLoadStart != null) {
              widget.onLoadStart!(controller, url);
            }

            setState(() {
              _progress = 0.0;
            });
          },
          onLoadStop: (controller, url) {
            if (widget.onLoadStop != null) {
              widget.onLoadStop!(controller, url);
            }

            _pullToRefreshController?.endRefreshing();
            setState(() => _progress = 1.0);
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              _pullToRefreshController?.endRefreshing();
            }

            setState(() => _progress = progress / 100);
          },
          onUpdateVisitedHistory: (controller, url, isReload) {
            if (widget.onUpdateVisitedHistory != null) {
              widget.onUpdateVisitedHistory!(controller, url, isReload);
            }
          },
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            return GeolocationPermissionShowPromptResponse(
                allow: true, origin: origin, retain: true);
          },
          onTitleChanged: (controller, title) {
            if (widget.onTitleChanged != null) {
              widget.onTitleChanged!(controller, title);
            }
          },
        ),
        if (_progress < 1.0)
          LinearProgressIndicator(
            value: _progress,
            color: MTheme.primary1,
          ),
      ],
    );
  }
}
