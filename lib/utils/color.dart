import 'dart:ui';

import 'package:flutter_randomcolor/flutter_randomcolor.dart';

int hexToInt(String hex) => int.parse('0xff${hex.substring(1)}');

Color hexToColor(String hex) => Color(hexToInt(hex));

int randomColor() =>
    RandomColor.getColorObject(Options(luminosity: Luminosity.light, alpha: 1))
        .value;
