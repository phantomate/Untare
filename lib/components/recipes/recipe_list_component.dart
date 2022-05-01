import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/components/bottomSheets/recipe_more_bottom_sheet_component.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/recipes/recipe_time_component.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/pages/recipe_detail_page.dart';

Widget recipeListComponent(Recipe recipe, BuildContext context) {
  BoxShadow boxShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 3.0,
  );

  return InkWell(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
      );
    },
    onLongPress: () {
      recipeMoreBottomSheet(context, recipe);
    },
    child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        leading: Container(
          width: 100,
          child: buildRecipeImage(recipe, BorderRadius.all(Radius.circular(10)), 100, boxShadow: boxShadow),
        ),
        title: Column(
          children: [
            Text(recipe.name),
            Row(
              children: [
                Row(
                  children: [
                    lastCooked(recipe),
                    Text(
                        recipe.rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                        )
                    ),
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber[300],
                    )
                  ],
                ),
              ],
            )
          ],
        ),
        trailing: buildRecipeTime(recipe)
    ),
  );
}

Widget lastCooked(Recipe recipe) {
  if (recipe.lastCooked != null) {
    return Row(
      children: [
        Icon(
          Icons.restaurant_outlined,
          size: 12,
        ),
        Text(
            recipe.lastCooked!,
            style: TextStyle(
              fontSize: 12,
            )
        ),
      ],
    );
  } else {
    return Text('');
  }
}