import 'dart:ui';

int hexToInt(String hex) => int.parse('0xff${hex.substring(1)}');

Color hexToColor(String hex) => Color(hexToInt(hex));
