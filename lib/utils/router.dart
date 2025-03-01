import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route _buildRoute(Widget widget, {required bool pushInto}) {
  if (Platform.isIOS) {
    return CupertinoPageRoute(builder: (context) => widget);
  } else {
    if (pushInto) {
      return MaterialPageRoute(builder: (context) => widget);
    }

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

void pushTo(BuildContext context, Widget widget, {bool pushInto = false}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.push(
      context,
      _buildRoute(widget, pushInto: pushInto),
    );
  });
}

void pushReplacement(BuildContext context, Widget widget,
    {bool pushInto = false}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushAndRemoveUntil(
        context, _buildRoute(widget, pushInto: pushInto), (_) => false);
  });
}
