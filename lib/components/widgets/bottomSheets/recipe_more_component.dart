import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/pages/recipe_upsert_page.dart';

Widget buildRecipeMore(BuildContext context, BuildContext btsContext, Recipe recipe) {
  return Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeUpsertPage(recipe: recipe)),
            );
          },
          icon: Icon(
            Icons.edit,
            color: Colors.black87,
          ),
          label: Text(
            'Edit',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
          },
          icon: Icon(
            Icons.calendar_today_outlined,
            color: Colors.black87,
          ),
          label: Text(
            'Add to Meal-Plan',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
          },
          icon: Icon(
            Icons.add_shopping_cart_outlined,
            color: Colors.black87,
          ),
          label: Text(
            'Add to Shopping-List',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
          },
          icon: Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
          ),
          label: Text(
            'Remove',
            style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    ),
  );
}