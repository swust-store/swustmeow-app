import 'package:flutter/material.dart';

class WillPopScopeBlocker extends StatefulWidget {
  const WillPopScopeBlocker({super.key, required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _WillPopScopeBlockerState();
}

class _WillPopScopeBlockerState extends State<WillPopScopeBlocker> {
  DateTime? lastPressed;

  bool _getCanPop() {
    if (lastPressed == null ||
        DateTime.now().difference(lastPressed!) > const Duration(seconds: 1)) {
      setState(() => lastPressed = DateTime.now());
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: _getCanPop(),
        child: widget.child,
      );
}
