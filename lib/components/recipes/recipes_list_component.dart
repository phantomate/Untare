import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
               thickness: 0.2,
               color: Colors.grey[400],
             ),
            ),
        ],
      );
    },
      childCount: recipesWidgetList.length,
    )
  );
}