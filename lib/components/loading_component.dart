import 'package:flutter/material.dart';

Widget buildLoading() {
  const padding = 15.0;

  return Builder(builder: (BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(padding),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor
          ),
        )
    );
  });
}