import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swustmeow/data/global_keys.dart';
import 'package:swustmeow/entity/uri_listener.dart';
import 'package:swustmeow/services/value_service.dart';
import 'package:swustmeow/utils/router.dart';
import 'package:swustmeow/views/course_table/course_table_page.dart';
import 'package:swustmeow/views/main_page.dart';
import 'package:uni_links/uni_links.dart';

class UriSubscriptionService {
  StreamSubscription<Uri?>? _linkSubscription;
  final List<UriListener> _listeners = [];

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

  void addListener(UriListener listener) {
    _listeners.add(listener);
  }

  void _handleUri(Uri? uri) {
    if (uri != null) {
      final host = uri.host;
      final path = uri.path;
      for (final entry
          in _listeners.where((e) => e.action == host && e.path == path)) {
        entry.callback(uri);
      }
    }
  }

  void initDefaultListeners(BuildContext context) {
    addListener(
      UriListener('jump', '/course_table', (uri) {
        final navigator = GlobalKeys.navigatorKey.currentState;
        if (navigator != null) {
          pushToWithoutContext(
            navigator,
            '/course_table',
            ValueService.currentCoursesContainer != null
                ? CourseTablePage(
                    containers: ValueService.coursesContainers,
                    currentContainer: ValueService.currentCoursesContainer!,
                    activities: ValueService.activities,
                    showBackButton: true,
                  )
                : MainPage(),
          );
        }
      }),
    );
  }
}
