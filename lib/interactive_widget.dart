import 'package:flutter/material.dart';

class InteractiveWidget {
  final Widget widget;
  final VoidCallback? onChange;

  InteractiveWidget(this.widget, this.onChange);
}
