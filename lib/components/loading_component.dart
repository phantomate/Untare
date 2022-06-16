import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildLoading() {
  final padding = 15.0;

  return Builder(builder: (BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor
          ),
        )
    );
  });
}