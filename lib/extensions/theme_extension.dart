import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData fromColor(Color color, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      fontFamily: 'Montserrat',
      colorScheme: ColorScheme.fromSeed(seedColor: color, brightness: brightness),
    );
  }

  static ThemeData fromScheme(ColorScheme colorScheme) {
    return ThemeData(
      brightness: colorScheme.brightness,
      fontFamily: 'Montserrat',
      colorScheme: colorScheme,
    );
  }
}
