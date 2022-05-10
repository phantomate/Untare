import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tare/components/widgets/bottom_sheets/meal_plan_more_component.dart';
import 'package:tare/models/meal_plan_entry.dart';

Future mealPlanMoreBottomSheet(BuildContext context, MealPlanEntry mealPlan) {
  return showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      duration: Duration(milliseconds: 300),
      context: context,
      builder: (btsContext) => Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(12),
        height: 200,
        child: Column(
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  color: Colors.grey[300]
              ),
              child: Text(
                mealPlan.recipe!.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87
                ),
              ),
            ),
            Expanded(
                child: buildMealPlanMore(context, btsContext, mealPlan)
            )
          ],
        ),
      )
  );
}