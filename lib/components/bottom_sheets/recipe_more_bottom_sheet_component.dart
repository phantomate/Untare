import 'package:flutter/material.dart';
import 'package:untare/components/widgets/bottom_sheets/recipe_more_component.dart';
import 'package:untare/models/recipe.dart';

Future recipeMoreBottomSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet(
      showDragHandle: true,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Wrap(
        spacing: 15,
        children: [
          buildRecipeMore(context, btsContext, recipe)
        ],
      ),
  );
}