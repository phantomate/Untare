import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/components/dialogs/delete_meal_type_dialog.dart';
import 'package:tare/components/dialogs/edit_meal_type_dialog.dart';

Future mealPlanMoreBottomSheet(BuildContext context) {
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
          spacing: 15,
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300] : Colors.grey[700]
              ),
              child: Text(
                'Meal plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
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
                          editMealTypeDialog(context);
                        },
                        icon: Icon(Icons.edit_outlined),
                        label: Text('Edit meal type'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(btsContext);
                          deleteMealTypeDialog(context);
                        },
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                        label: Text(
                          'Remove meal type',
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