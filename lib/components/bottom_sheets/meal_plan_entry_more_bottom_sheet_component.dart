import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_event.dart';
import 'package:tare/components/dialogs/upsert_meal_plan_entry_dialog.dart';
import 'package:tare/models/meal_plan_entry.dart';

import 'recipe_shopping_list_bottom_sheet_component.dart';

Future mealPlanEntryMoreBottomSheet(BuildContext context, MealPlanEntry mealPlan) {
  MealPlanBloc _mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);

  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(12),
        child: Wrap(
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300] : Colors.grey[700]
              ),
              child: Text(
                mealPlan.recipe!.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                ),
              ),
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Column(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(btsContext);
                          upsertMealPlanEntryDialog(context, mealPlan: mealPlan, referer: 'edit');
                        },
                        icon: Icon(Icons.edit_outlined),
                        label: Text('Edit'),
                      ),
                      if (mealPlan.recipe != null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(btsContext);
                            recipeShoppingListBottomSheet(context, mealPlan.recipe!);
                          },
                          icon: Icon(Icons.add_shopping_cart_outlined),
                          label: Text('Add to shopping list'),
                        ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(btsContext);
                          _mealPlanBloc.add(DeleteMealPlan(mealPlan: mealPlan));
                        },
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                        label: Text(
                          'Remove from meal plan',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ]
                )
            )
          ],
        ),
      )
  );
}