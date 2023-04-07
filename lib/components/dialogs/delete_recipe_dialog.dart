import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/blocs/recipe/recipe_event.dart';
import 'package:untare/models/recipe.dart';

Future deleteRecipeDialog(BuildContext context, Recipe recipe) async {
  RecipeBloc recipeBloc = BlocProvider.of<RecipeBloc>(context);

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Wrap(
              spacing: 15,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(AppLocalizations.of(context)!.confirmRemoveFood.replaceFirst('%s', recipe.name), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialButton(
                        color: Colors.redAccent,
                        onPressed: () {
                            recipeBloc.add(DeleteRecipe(recipe: recipe));
                            Navigator.pop(dContext);
                        },
                        child: Text(AppLocalizations.of(context)!.remove)
                    ),
                    MaterialButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.pop(dContext);
                        },
                        child: Text(AppLocalizations.of(context)!.cancel)
                    )
                  ],
                )
              ],
            )
        )
    );
  });
}