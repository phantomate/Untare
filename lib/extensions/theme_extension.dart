import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(Color color) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Montserrat',
      colorScheme: ColorScheme.fromSeed(seedColor: color),
    );
  }

  static ThemeData darkTheme(Color color) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',
      colorScheme: ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark),
    );
  }
}
