import 'package:flutter/material.dart';

Widget buildRecipesList(List<Widget> recipesWidgetList) {
  return SliverList(
    delegate: SliverChildBuilderDelegate((context, index) {
      return Column(
        children: <Widget>[
          recipesWidgetList[index],

          if(index != (recipesWidgetList.length - 1))
            Padding(
             padding: const EdgeInsets.only(left: 10, right: 10),
              child: Divider(
               thickness: 0.5,
               color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
             ),
            ),
        ],
      );
    },
      childCount: recipesWidgetList.length,
    )
  );
}