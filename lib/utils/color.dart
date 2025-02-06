import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';

int hexToInt(String hex) => int.parse('0xff${hex.substring(1)}');

Color hexToColor(String hex) => Color(hexToInt(hex));

int randomColor() =>
    RandomColor.getColorObject(Options(luminosity: Luminosity.light, alpha: 1))
        .toInt();

/// 哈希函数将字符串转为颜色
Color generateColorFromString(String string, {double minBrightness = 0.5}) {
  // 对名称进行 MD5 哈希，确保唯一
  var bytes = utf8.encode(string);
  var hash = md5.convert(bytes).toString();

  // 将哈希字符串的部分转换成 RGB 分量
  int r = int.parse(hash.substring(0, 2), radix: 16);
  int g = int.parse(hash.substring(2, 4), radix: 16);
  int b = int.parse(hash.substring(4, 6), radix: 16);

  // 转换为 HSL 并限制最小亮度，确保不会太暗
  HSLColor hsl = HSLColor.fromColor(Color.fromARGB(255, r, g, b));
  double brightness = max(hsl.lightness, minBrightness);

  return hsl.withLightness(brightness).toColor();
}

int _floatToInt8(double x) {
  return (x * 255.0).round() & 0xff;
}

extension ColorExtension on Color {
  int toInt() {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  /// darkness: [[0, 1]]
  Color withDarkness(double darkness) {
    darkness = darkness > 1
        ? 1
        : darkness < 0
            ? 0
            : darkness;
    final d = (1 - darkness);
    return Color.fromARGB(
      (a * 255).toInt(),
      (r * 255 * d).toInt(),
      (g * 255 * d).toInt(),
      (b * 255 * d).toInt(),
    );
  }
}
