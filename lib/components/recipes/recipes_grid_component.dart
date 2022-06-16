import 'package:flutter/widgets.dart';

Widget buildRecipesGrid(List<Widget> recipesWidgetList, BoxConstraints constraints) {
  int axisCount = ((constraints.maxWidth + 50) / 200).floor();

  return SliverGrid(
    delegate: SliverChildBuilderDelegate((context, index) {
      return recipesWidgetList[index];
    },
      childCount: recipesWidgetList.length,
    ),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (axisCount > 1) ? axisCount : 1,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        mainAxisExtent: 196
    ),
  );
}