import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

Route _buildRoute(Widget widget, {required bool pushInto}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // 从右侧滑入
      const end = Offset(0.0, 0.0); // 最终位置
      const curve = Curves.easeInOut; // 动画曲线

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return pushInto
          ? FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            )
          : SlideTransition(
              position: offsetAnimation,
              child: child,
            );
    },
  );
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
