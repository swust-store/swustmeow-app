import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';

int hexToInt(String hex) => int.parse('0xff${hex.substring(1)}');

Color hexToColor(String hex) => Color(hexToInt(hex));

int randomColor() =>
    RandomColor.getColorObject(Options(luminosity: Luminosity.light, alpha: 1))
        .value;

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
