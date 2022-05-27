import 'package:flutter/material.dart';
import 'package:tare/components/widgets/recipe_shopping_list_stateful_widget.dart';

import 'package:tare/models/recipe.dart';

Future recipeShoppingListBottomSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet(
    isScrollControlled: true,
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
                recipe.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ),
            Container(height: 600,child: RecipeShoppingListWidget(recipe: recipe, btsContext: btsContext))
          ],
        ),
      )
  );
}