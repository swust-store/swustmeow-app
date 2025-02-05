import 'package:flutter/cupertino.dart';

double calculateStringLength(String input) {
  double length = 0;

  for (final rune in input.runes) {
    String char = String.fromCharCode(rune);

    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(char)) {
      length += 1; // 中文字符
    } else if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
      length += 0.6; // 英文字符
    } else if (RegExp(r'[\d\W]').hasMatch(char)) {
      length += 0.5; // 数字和符号
    }
  }

  return length;
}

String overflowed(String string, int maxLen) {
  double realMaxLen = maxLen.toDouble();
  for (final char in string.characters) {
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

bool numberOnly(String string) =>
    string.characters
        .where((char) => RegExp(r'^[0-9]$').hasMatch(char))
        .length ==
    string.characters.length;

extension StringExtension on String {
  String? get emptyThenNull => trim() == '' ? null : this;

  bool get isContentEmpty => isEmpty || trim() == '';

  /// 获取纯净字符串，删除其中的空格和换行，
  /// 并将所有的字母变为小写，以便于搜索和匹配。
  String get pureString =>
      replaceAll(' ', '').replaceAll('\n', '').trim().toLowerCase();

  String get withoutPunctuation => replaceAll(RegExp(r'[^\w\s]'), '');
}
