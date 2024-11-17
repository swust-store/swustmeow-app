import 'package:flutter/material.dart';

void pushTo(BuildContext context, Widget widget) => WidgetsBinding.instance
    .addPostFrameCallback((_) => Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widget,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child))));
