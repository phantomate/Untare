import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untare/components/bottom_sheets/meal_plan_entry_more_bottom_sheet_component.dart';
import 'package:untare/components/bottom_sheets/recipe_more_bottom_sheet_component.dart';
import 'package:untare/components/recipes/recipe_image_component.dart';
import 'package:untare/components/recipes/recipe_time_component.dart';
import 'package:untare/models/meal_plan_entry.dart';

import 'package:untare/models/recipe.dart';
import 'package:untare/pages/recipe_detail_page.dart';

Widget recipeGridComponent(Recipe recipe, BuildContext context, {String? referer, MealPlanEntry? mealPlan, bool? disabled}) {
  BoxDecoration recipeTimeDecoration = BoxDecoration(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(30)
  );

  List<Widget> widgets = [];
  List<Widget> joinedWidgets = [];
  Widget? lastCookedWidget = lastCooked(recipe, context);
  Widget? ratingWidget = rating(recipe, context);

  if (lastCookedWidget != null) {
    widgets.add(lastCookedWidget);
  }
  if (ratingWidget != null) {
    widgets.add(ratingWidget);
  }
  if (mealPlan != null) {
    widgets.add(
      Flexible(child: Text(mealPlan.mealType.name, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onTertiaryContainer)))
    );
  }

  for (int i = 0;  i < widgets.length; i++) {
    if (i != widgets.length - 1)  {
      joinedWidgets.add(widgets[i]);
      joinedWidgets.add(const SizedBox(width: 8));
    } else {
      joinedWidgets.add(widgets[i]);
    }
  }

  return Card(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: () {
          if ((disabled != null && !disabled) || disabled == null) {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe, referer: referer)),
            );
          }
        },
        onLongPress: () {
          if (mealPlan != null) {
            mealPlanEntryMoreBottomSheet(context, mealPlan);
          } else {
            recipeMoreBottomSheet(context, recipe);
          }
        },
        child: Container(
          foregroundDecoration: (disabled != null && disabled) ? const BoxDecoration(
            color: Colors.grey,
            backgroundBlendMode: BlendMode.saturation,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ) : null,
          child: Column(
            children: [
              Stack(
                children: [
                  buildRecipeImage(recipe, const BorderRadius.vertical(top: Radius.circular(10)), 133, referer: referer),
                  Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.topRight,
                    child: buildRecipeTime(recipe, boxDecoration: recipeTimeDecoration),
                  ),
                  if (recipe.lastCooked != null || (recipe.rating != null && recipe.rating! > 0) || mealPlan != null)
                    Container(
                      height: 133,
                      width: double.maxFinite,
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(30)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: joinedWidgets,
                        ),
                      ),
                    )
                ],
              ),
              Container(
                height: 55,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                padding: const EdgeInsets.only(top: 6, right: 15, bottom: 8, left: 15),
                child: Text(
                  recipe.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        )
    ),
  );
}

Widget? lastCooked(Recipe recipe, BuildContext context) {
  if (recipe.lastCooked != null) {
    return Row(
      children: [
        const Icon(
            Icons.restaurant_outlined,
            size: 11
        ),
        const SizedBox(width: 2),
        Text(
            DateFormat('dd.MM.yy').format(DateTime.parse(recipe.lastCooked!).toLocal()),
            style: const TextStyle(fontSize: 11)
        )
      ],
    );
  }
  return null;
}

Widget? rating (Recipe recipe, BuildContext context) {
  if (recipe.rating != null && recipe.rating! > 0) {
    return Row(
      children: [
        Text(
            recipe.rating.toString(),
            style: const TextStyle(
                fontSize: 11,
            )
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.star,
          size: 11,
          color: Colors.amberAccent,
        ),
      ],
    );
  }
  return null;
}