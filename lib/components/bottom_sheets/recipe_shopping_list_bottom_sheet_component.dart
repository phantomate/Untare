import 'package:flutter/material.dart';
import 'package:untare/components/widgets/recipe_shopping_list_stateful_widget.dart';

import 'package:untare/models/recipe.dart';

Future recipeShoppingListBottomSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet(
    isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        child: Wrap(
          children: [
            Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                recipe.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 600,child: RecipeShoppingListWidget(recipe: recipe, btsContext: btsContext))
          ],
        ),
      )
  );
}