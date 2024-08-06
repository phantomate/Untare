import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:untare/blocs/meal_plan/meal_plan_event.dart';
import 'package:untare/components/dialogs/upsert_meal_plan_entry_dialog.dart';
import 'package:untare/models/meal_plan_entry.dart';

import 'recipe_shopping_list_bottom_sheet_component.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future mealPlanEntryMoreBottomSheet(BuildContext context, MealPlanEntry mealPlan) {
  MealPlanBloc mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);

  return showModalBottomSheet(
      showDragHandle: true,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Wrap(
        children: [
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
              child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pop(btsContext);
                        upsertMealPlanEntryDialog(context, mealPlan: mealPlan, referer: 'edit');
                      },
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(AppLocalizations.of(context)!.edit)
                    ),
                    if (mealPlan.recipe != null)
                      ListTile(
                        onTap: () {
                          Navigator.pop(btsContext);
                          recipeShoppingListBottomSheet(context, mealPlan.recipe!);
                        },
                        leading: const Icon(Icons.add_shopping_cart_outlined),
                        title: Text(AppLocalizations.of(context)!.addToShoppingList)
                      ),
                    const Divider(),
                    ListTile(
                      onTap: () {
                        Navigator.pop(btsContext);
                        mealPlanBloc.add(DeleteMealPlan(mealPlan: mealPlan));
                      },
                      leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      title: Text(
                        AppLocalizations.of(context)!.mealPlanRemove,
                        style: const TextStyle(color: Colors.redAccent)
                      )
                    )
                  ]
              )
          )
        ],
      ),
  );
}