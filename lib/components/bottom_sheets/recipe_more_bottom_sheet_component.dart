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
          buildRecipeMore(context, btsContext, recipe)
        ],
      ),
  );
}