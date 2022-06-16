import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/models/recipe.dart';

Widget? buildRecipeTime(Recipe recipe, {BoxDecoration? boxDecoration, Color? color}) {
  int recipeSumTime = (recipe.workingTime ?? 0) + (recipe.waitingTime ?? 0);

  if (recipeSumTime > 0) {
    return Container(
      decoration: boxDecoration,
      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 11,
            color: color,
          ),
          SizedBox(width: 2),
          Text(
            recipeSumTime.toString() + ' min',
            style: TextStyle(
              fontSize: 11,
              color: color
            ),
          ),
        ],
      ),
    );
  } else {
    return null;
  }
}