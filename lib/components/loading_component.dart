import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/constants/colors.dart';

Widget buildLoading() {
  final padding = 15.0;

  return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primaryColor
        ),
      )
  );
}