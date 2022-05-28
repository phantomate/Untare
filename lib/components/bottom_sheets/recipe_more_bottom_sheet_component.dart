import 'package:flutter/material.dart';
import 'package:tare/components/widgets/bottom_sheets/recipe_more_component.dart';
import 'package:tare/models/recipe.dart';

Future recipeMoreBottomSheet(BuildContext context, Recipe recipe) {
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
              height: 44,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            buildRecipeMore(context, btsContext, recipe)
          ],
        ),
      )
  );
}