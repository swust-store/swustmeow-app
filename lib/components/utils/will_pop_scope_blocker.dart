import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swustmeow/utils/common.dart';

class WillPopScopeBlocker extends StatefulWidget {
  const WillPopScopeBlocker({super.key, required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _WillPopScopeBlockerState();
}

class _WillPopScopeBlockerState extends State<WillPopScopeBlocker> {
  DateTime? _lastPressed;
  bool _canPop = false;

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (bool didPop, _) {
        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _refresh(() {
            _canPop = false;
            _lastPressed = now;
          });
          showInfoToast(context, '再次返回以退出');
          return;
        } else {
          _refresh(() {
            _canPop = true;
            _lastPressed = null;
          });
          exit(0);
        }
      },
      child: widget.child,
    );
  }
}
