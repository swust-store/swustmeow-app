import 'package:flutter/material.dart';

void pushTo(BuildContext context, Widget widget) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 从右侧滑入
          const end = Offset(0.0, 0.0); // 最终位置
          const curve = Curves.easeInOut; // 动画曲线

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  });
}
