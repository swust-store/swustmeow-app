import 'package:flutter/cupertino.dart';

String overflowed(String string, int maxLen) {
  double realMaxLen = maxLen.toDouble();
  for (final char in string.split('')) {
    realMaxLen += (char.codeUnitAt(0) & ~0x7F) == 0 ? 0.5 : 0;
  }
  int floor = realMaxLen.floor();
  return string.length <= floor
      ? string
      : '${string.substring(0, floor - 1)}...';
}

String latinOnly(String string) => string.characters
    .where((char) => RegExp(r'^[a-zA-Z0-9]$').hasMatch(char))
    .string;

extension StringExtension on String {
  String? get emptyThenNull => trim() == '' ? null : this;
}
