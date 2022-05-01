import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/components/bottomSheets/recipe_more_bottom_sheet_component.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/recipes/recipe_time_component.dart';

import 'package:tare/models/recipe.dart';
import 'package:tare/pages/recipe_detail_page.dart';

Widget recipeGridComponent(Recipe recipe, BuildContext context) {
  BoxDecoration recipeTimeDecoration = BoxDecoration(
      color: Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(30)
  );

  return Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    child:InkWell(
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
      child: Column(
        children: [
          Stack(
            children: [
              buildRecipeImage(recipe, BorderRadius.vertical(top: Radius.circular(10)), 120),
              Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.topRight,
                child: buildRecipeTime(recipe, boxDecoration: recipeTimeDecoration),
              )
            ],
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              padding: EdgeInsets.only(top: 10, right: 5, bottom: 10, left: 15),
              child: Text(
                recipe.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          )
        ],
      )
    ),
  );
}