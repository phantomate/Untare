import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/recipes/recipe_list_component.dart';
import 'package:tare/components/recipes/recipe_time_component.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/services/api/api_recipe.dart';

Widget recipeTypeAheadFormField(Recipe? recipe, GlobalKey<FormBuilderState> _formBuilderKey, BuildContext context, {String? referer}) {
  final ApiRecipe _apiRecipe = ApiRecipe();
  final _recipeTextController = TextEditingController();

  if (recipe != null) {
    _recipeTextController.text = recipe.name;
  }

  return FormBuilderTypeAhead<Recipe>(
    name: 'recipe',
    controller: _recipeTextController,
    initialValue: recipe,
    enabled: (referer == 'meal-plan' || referer == 'edit'),
    selectionToTextTransformer: (recipe) => recipe.name,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.recipe
    ),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required()
    ]),
    itemBuilder: (context, recipe) {
      return ListTile(
          contentPadding: const EdgeInsets.all(5),
          leading: Container(
            width: 100,
            child: buildRecipeImage(
                recipe, BorderRadius.all(Radius.circular(10)), 100,
                boxShadow: BoxShadow(
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
      return await _apiRecipe.getRecipeList(query, false, 1, 25, null);
    },
    onSuggestionSelected: (suggestion) {
      _recipeTextController.text = suggestion.name;
    },
    onChanged: (Recipe? recipe) {
      if (_formBuilderKey.currentState!.fields['servings'] != null && recipe != null) {
        _formBuilderKey.currentState!.fields['servings']!.didChange(recipe.servings.toString());
      }
    },
    onSaved: (Recipe? formRecipe) {
      // Invalidate empty string because type ahead field isn't aware
      if (_recipeTextController.text.isEmpty) {
        _formBuilderKey.currentState!.fields['recipe']!.didChange(null);
      }

      if (formRecipe == null) {
        _recipeTextController.text = '';
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}