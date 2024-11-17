import 'package:flutter/material.dart';

class TextPlaceholder extends StatelessWidget {
  const TextPlaceholder(this.line, {super.key});

  final int line;

  @override
  Widget build(BuildContext context) => Text('\n' * line);
}
