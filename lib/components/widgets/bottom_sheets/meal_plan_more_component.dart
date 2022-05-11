import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_event.dart';
import 'package:tare/components/bottom_sheets/meal_plan_upsert_bottom_sheet_component.dart';
import 'package:tare/components/bottom_sheets/recipe_shopping_list_bottom_sheet_component.dart';
import 'package:tare/models/meal_plan_entry.dart';

Widget buildMealPlanMore(BuildContext context, BuildContext btsContext, MealPlanEntry mealPlan) {
  MealPlanBloc _mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);

  return Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
            mealPlanUpsertBottomSheet(context, mealPlan: mealPlan, referer: 'edit');
          },
          icon: Icon(
            Icons.edit_outlined,
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
        if (mealPlan.recipe != null)
          TextButton.icon(
            onPressed: () {
              Navigator.pop(btsContext);
              recipeShoppingListBottomSheet(context, mealPlan.recipe!);
            },
            icon: Icon(
              Icons.add_shopping_cart_outlined,
              color: Colors.black87,
            ),
            label: Text(
              'Add to shopping list',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(btsContext);
            _mealPlanBloc.add(DeleteMealPlan(mealPlan: mealPlan));
          },
          icon: Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
          ),
          label: Text(
            'Remove from meal plan',
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