import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

class UriSubscriptionService {
  StreamSubscription<Uri?>? _linkSubscription;
  final Map<String, List<Function(Uri uri)>> _listeners = {};

  Future<void> initUriListener() async {
    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      debugPrint('收到 URI: $uri');
      _handleUri(uri);
    }, onError: (err) {
      debugPrint('无法获取 URI：$err');
    });

    final initialUri = await getInitialUri();
    if (initialUri != null) {
      debugPrint('初始 URI: $initialUri');
      _handleUri(initialUri);
    }
  }

  Future<void> dispose() async {
    _listeners.clear();
    await _linkSubscription?.cancel();
  }

  void addListener(String path, Function(Uri uri) callback) {
    final list = _listeners[path] ?? [];
    list.add(callback);
    _listeners[path] = list;
  }

  void _handleUri(Uri? uri) {
    if (uri != null) {
      final path = uri.path;
      for (final entry in _listeners.entries.where((e) => e.key == path)) {
        final listeners = entry.value;
        for (final listener in listeners) {
          listener(uri);
        }
      }
    }
  }
}
