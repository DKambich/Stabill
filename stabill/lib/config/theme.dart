import 'package:flutter/material.dart';

var colorSchemeLight = ColorScheme.fromSeed(
  seedColor: Colors.green,
  brightness: Brightness.light,
);

var themeLight = ThemeData.from(colorScheme: colorSchemeLight).copyWith(
  appBarTheme: AppBarTheme(
    backgroundColor: colorSchemeLight.secondaryContainer,
    shadowColor: colorSchemeLight.shadow,
  ),
);
