import 'package:flutter/material.dart';

class InteractiveWidget {
  final Widget widget;
  final VoidCallback? onChange;
  final bool clickable;

  InteractiveWidget(this.widget, {this.onChange, this.clickable = true});
}
