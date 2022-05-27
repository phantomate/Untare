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
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: primaryColor,
            )
        ),
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
      primaryTextTheme: TextTheme(
        bodyText1: TextStyle(
          color: Colors.black87
        ),
        bodyText2: TextStyle(
            color: Colors.grey[600]
        ),
        overline: TextStyle(
            color: Colors.grey[300]
        )
      )
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',
      iconTheme: IconThemeData(color: Colors.grey[50]),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: Colors.grey[400],
        suffixIconColor: Colors.grey[400],
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor,
          )
        ),
        labelStyle: TextStyle(
          color: Colors.grey[600],
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[700]!,
          )
        )
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              primary: Colors.white
          )
      ),
      buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary
      ),
      primaryTextTheme: TextTheme(
        bodyText2: TextStyle(
          color: Colors.grey[300]
        ),
        overline: TextStyle(
          color: Colors.grey[600]
        )
      )
    );
  }
}