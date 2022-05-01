import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/components/widgets/bottomSheets/recipe_more_component.dart';
import 'package:tare/models/recipe.dart';

Future recipeMoreBottomSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        margin: const EdgeInsets.all(12),
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[300]
              ),
              child: Text(
                recipe.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87
                ),
              ),
            ),
            Expanded(
                child: buildRecipeMore(context, btsContext, recipe)
            )
          ],
        ),
      )
  );
}