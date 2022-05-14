import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_state.dart';
import 'package:tare/components/widgets/bottom_sheets/meal_plan_upsert_component.dart';
import 'package:tare/models/meal_plan_entry.dart';
import 'package:tare/models/recipe.dart';

Future mealPlanUpsertBottomSheet(BuildContext context, {MealPlanEntry? mealPlan, DateTime? date, Recipe? recipe, String? referer}) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(12),
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  color: Colors.grey[300]
              ),
              child: Text(
                'Add to meal plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87
                ),
              ),
            ),
            BlocListener<MealPlanBloc, MealPlanState>(
              listener: (context, state) {
                Navigator.pop(btsContext);
              },
              child: Expanded(
                  child: buildMealPlanUpsert(context, mealPlan: mealPlan, date: date, recipe: recipe, referer: referer)
              )
            )
          ],
        ),
      )
  );
}