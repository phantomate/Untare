import 'package:flutter/material.dart';
import 'package:tare/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.light,
      fontFamily: 'Montserrat',
      iconTheme: IconThemeData(color: Colors.black87),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',
      iconTheme: IconThemeData(color: Colors.grey[50]),
    );
  }
}