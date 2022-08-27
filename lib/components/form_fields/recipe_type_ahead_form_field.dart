import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/components/recipes/recipe_image_component.dart';
import 'package:untare/components/recipes/recipe_list_component.dart';
import 'package:untare/components/recipes/recipe_time_component.dart';
import 'package:untare/futures/future_api_cache_recipes.dart';
import 'package:untare/models/recipe.dart';

Widget recipeTypeAheadFormField(Recipe? recipe, GlobalKey<FormBuilderState> formBuilderKey, BuildContext context, {String? referer}) {
  final recipeTextController = TextEditingController();

  if (recipe != null) {
    recipeTextController.text = recipe.name;
  }

  return FormBuilderTypeAhead<Recipe>(
    name: 'recipe',
    controller: recipeTextController,
    initialValue: recipe,
    enabled: (referer == 'meal-plan' || referer == 'edit'),
    selectionToTextTransformer: (recipe) => recipe.name,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.recipe
    ),
    validator: FormBuilderValidators.compose([
      if (referer != 'meal-plan' && referer != 'edit')
        FormBuilderValidators.required()
    ]),
    itemBuilder: (context, recipe) {
      return ListTile(
          contentPadding: const EdgeInsets.all(5),
          leading: SizedBox(
            width: 100,
            child: buildRecipeImage(
                recipe, const BorderRadius.all(Radius.circular(10)), 100,
                boxShadow: const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3.0,
                ),
                referer: referer),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.name),
              if (recipe.lastCooked != null || (recipe.rating != null && recipe.rating! > 0))
                Row(
                  children: [
                    Row(
                      children: [
                        lastCooked(recipe, context),
                        rating(recipe, context)
                      ],
                    ),
                  ],
                )
            ],
          ),
          trailing: buildRecipeTime(recipe)
      );
    },
    suggestionsCallback: (query) async {
      return await getRecipesFromApiCache(query);
    },
    onSuggestionSelected: (suggestion) {
      recipeTextController.text = suggestion.name;
    },
    onChanged: (Recipe? recipe) {
      if (formBuilderKey.currentState!.fields['servings'] != null && recipe != null) {
        formBuilderKey.currentState!.fields['servings']!.didChange(recipe.servings.toString());
      }
    },
    onSaved: (Recipe? formRecipe) {
      // Invalidate empty string because type ahead field isn't aware
      if (recipeTextController.text.isEmpty) {
        formBuilderKey.currentState!.fields['recipe']!.didChange(null);
      }

      if (formRecipe == null) {
        recipeTextController.text = '';
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}