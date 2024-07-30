import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Montserrat',
      iconTheme: const IconThemeData(color: Colors.black87),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: Colors.grey[600],
        suffixIconColor: Colors.grey[600],
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[800]!,
            )
        ),
        labelStyle: const TextStyle(
          color: Colors.black26,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black12,
            )
        )
      ),
      appBarTheme: const AppBarTheme(
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
          foregroundColor: Colors.black87
        )
      ),
      buttonTheme: const ButtonThemeData(
        textTheme: ButtonTextTheme.primary
      ),
      primaryTextTheme: TextTheme(
        bodyMedium: const TextStyle(
          color: Colors.black87
        ),
        bodySmall: TextStyle(
            color: Colors.grey[600]
        ),
        labelMedium: TextStyle(
            color: Colors.grey[300]
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating
      ),
      checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3)
          )
      )
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',
      iconTheme: IconThemeData(color: Colors.grey[50]),
      inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: Colors.grey[400],
        suffixIconColor: Colors.grey[400],
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[300]!,
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
              foregroundColor: Colors.white
          )
      ),
      buttonTheme: const ButtonThemeData(
          textTheme: ButtonTextTheme.primary
      ),
      primaryTextTheme: TextTheme(
        bodySmall: TextStyle(
          color: Colors.grey[300]
        ),
        labelMedium: TextStyle(
          color: Colors.grey[600]
        )
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[300]
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3)
        )
      )
    );
  }
}