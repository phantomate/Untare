import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untare/components/bottom_sheets/meal_plan_entry_more_bottom_sheet_component.dart';
import 'package:untare/components/bottom_sheets/recipe_more_bottom_sheet_component.dart';
import 'package:untare/components/recipes/recipe_image_component.dart';
import 'package:untare/components/recipes/recipe_time_component.dart';
import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/pages/recipe_detail_page.dart';

Widget recipeListComponent(Recipe recipe, BuildContext context, {String? referer, MealPlanEntry? mealPlan, bool? disabled}) {
  BoxShadow boxShadow = const BoxShadow(
    color: Colors.black12,
    blurRadius: 3.0,
  );

  return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      contentPadding: (recipe.lastCooked != null || (recipe.rating != null && recipe.rating! > 0)) ? const EdgeInsets.fromLTRB(5, 0 ,5, 0) : const EdgeInsets.fromLTRB(5, 2 ,5, 2),
      leading: Container(
        width: 100,
          foregroundDecoration: (disabled != null && disabled) ? const BoxDecoration(
              color: Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
              borderRadius: BorderRadius.all(Radius.circular(10))
          ) : null,
        child: buildRecipeImage(recipe, const BorderRadius.all(Radius.circular(10)), 100, boxShadow: boxShadow, referer: referer),
      ),
      title: Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: (recipe.lastCooked != null || (recipe.rating != null && recipe.rating! > 0) || mealPlan != null) ?
      Row(
        children: [
          lastCooked(recipe, context),
          rating(recipe, context),
          if (mealPlan != null)
            Flexible(
                child: Text(mealPlan.mealType.name, style: TextStyle(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8), fontSize: 12))
            )
        ],
      ) : null,
      trailing: buildRecipeTime(recipe)
  );
}

Widget lastCooked(Recipe recipe, BuildContext context) {
  if (recipe.lastCooked != null) {
    return Row(
      children: [
        Icon(
          Icons.restaurant_outlined,
          size: 12,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)
        ),
        const SizedBox(width: 2),
        Text(
            DateFormat('dd.MM.yy').format(DateTime.parse(recipe.lastCooked!).toLocal()),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8), fontSize: 12)
        ),
        const SizedBox(width: 8)
      ],
    );
  }
  return const Text('');
}

Widget rating (Recipe recipe, BuildContext context) {
  if (recipe.rating != null && recipe.rating! > 0) {
    return Row(
      children: [
        Text(
            recipe.rating.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)
            )
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.star,
          size: 12,
          color: Colors.amberAccent,
        ),
        const SizedBox(width: 8)
      ],
    );
  }
  return const Text('');
}