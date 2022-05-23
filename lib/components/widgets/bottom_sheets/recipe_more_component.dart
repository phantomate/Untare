import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/components/bottom_sheets/recipe_shopping_list_bottom_sheet_component.dart';
import 'package:tare/components/dialogs/upsert_meal_plan_entry_dialog.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/pages/recipe_upsert_page.dart';

Widget buildRecipeMore(BuildContext context, BuildContext btsContext, Recipe recipe) {
  RecipeBloc _recipeBloc = BlocProvider.of<RecipeBloc>(context);

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: Column(
      children: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeUpsertPage(recipe: recipe)),
            );
          },
          icon: Icon(Icons.edit_outlined),
          label: Text('Edit'),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
            upsertMealPlanEntryDialog(context, recipe: recipe, referer: 'recipe');
          },
          icon: Icon(Icons.calendar_today_outlined),
          label: Text('Add to meal plan'),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
            recipeShoppingListBottomSheet(context, recipe);
          },
          icon: Icon(Icons.add_shopping_cart_outlined),
          label: Text('Add to shopping list'),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
            _recipeBloc.add(DeleteRecipe(recipe: recipe));
          },
          icon: Icon(Icons.delete_outline, color: Colors.redAccent),
          label: Text(
            'Remove',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}