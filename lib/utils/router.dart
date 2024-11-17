import 'package:flutter/material.dart';

void pushTo(BuildContext context, Widget widget) => WidgetsBinding.instance
    .addPostFrameCallback((_) => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => widget)));
