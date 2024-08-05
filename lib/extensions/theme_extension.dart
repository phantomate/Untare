import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Montserrat',
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey, brightness: Brightness.dark),
    );
  }
}
