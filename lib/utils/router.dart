import 'dart:io' show Platform; // 导入 Platform 类

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart'; // 导入 CupertinoPageRoute
import 'package:flutter/material.dart';

Route _buildRoute(Widget widget, {required bool pushInto}) {
  if (Platform.isIOS) {
    return CupertinoPageRoute(
      builder: (context) => widget,
    );
  } else {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return pushInto
            ? FadeThroughTransition(
                animation: animation,
                secondaryAnimation: AlwaysStoppedAnimation(0.0),
                child: child,
              )
            : SlideTransition(
                position: offsetAnimation,
                child: child,
              );
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
