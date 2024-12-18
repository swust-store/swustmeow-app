import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../data/values.dart';

FThemeData getFThemeData() => switch (Values.themeMode) {
      null ||
      ThemeMode.system =>
        Values.isDarkMode ? FThemes.zinc.dark : FThemes.zinc.light,
      ThemeMode.light => FThemes.zinc.dark,
      ThemeMode.dark => FThemes.zinc.light,
    };
