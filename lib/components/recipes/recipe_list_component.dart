import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tare/components/bottom_sheets/meal_plan_entry_more_bottom_sheet_component.dart';
import 'package:tare/components/bottom_sheets/recipe_more_bottom_sheet_component.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/recipes/recipe_time_component.dart';
import 'package:tare/models/meal_plan_entry.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/pages/recipe_detail_page.dart';

Widget recipeListComponent(Recipe recipe, BuildContext context, {String? referer, MealPlanEntry? mealPlan}) {
  BoxShadow boxShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 3.0,
  );

  return InkWell(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe, referer: referer)),
      );
    },
    onLongPress: () {
      if (mealPlan != null) {
        mealPlanEntryMoreBottomSheet(context, mealPlan);
      } else {
        recipeMoreBottomSheet(context, recipe);
      }
    },
    child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        leading: Container(
          width: 100,
          child: buildRecipeImage(recipe, BorderRadius.all(Radius.circular(10)), 100, boxShadow: boxShadow, referer: referer),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.name),
            if (recipe.lastCooked != null || (recipe.rating != null && recipe.rating! > 0) || mealPlan != null)
              Row(
                children: [
                  Row(
                    children: [
                      lastCooked(recipe, context),
                      rating(recipe, context),
                      if (mealPlan != null)
                        Text(mealPlan.mealType.name, style: TextStyle(color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[600] : Colors.grey, fontSize: 12))
                    ],
                  ),
                ],
              )
          ],
        ),
        trailing: buildRecipeTime(recipe)
    )
  );
}

Widget lastCooked(Recipe recipe, BuildContext context) {
  if (recipe.lastCooked != null) {
    return Row(
      children: [
        Icon(
          Icons.restaurant_outlined,
          size: 12,
          color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[600] : Colors.grey
        ),
        SizedBox(width: 2),
        Text(
            DateFormat('dd.MM.yy').format(DateTime.parse(recipe.lastCooked!)),
            style: TextStyle(color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[600] : Colors.grey, fontSize: 12)
        ),
        SizedBox(width: 8)
      ],
    );
  }
  return Text('');
}

Widget rating (Recipe recipe, BuildContext context) {
  if (recipe.rating != null && recipe.rating! > 0) {
    return Row(
      children: [
        Text(
            recipe.rating.toString(),
            style: TextStyle(
              fontSize: 12,
              color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[600] : Colors.grey
            )
        ),
        SizedBox(width: 2),
        Icon(
          Icons.star,
          size: 12,
          color: Colors.amberAccent,
        ),
        SizedBox(width: 8)
      ],
    );
  }
  return Text('');
}