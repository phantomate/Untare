import 'package:flutter/material.dart';
import 'package:tare/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.light,
      fontFamily: 'Montserrat',
      iconTheme: IconThemeData(color: Colors.black87),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: Colors.grey[600],
        suffixIconColor: Colors.grey[600],
        border: OutlineInputBorder(),
        labelStyle: TextStyle(
          color: Colors.black26,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black12,
            )
        )
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
          color: Colors.black87
        ),
        toolbarTextStyle: TextStyle(
            color: Colors.black87
        ),
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.black87
        )
      ),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.green
      )
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