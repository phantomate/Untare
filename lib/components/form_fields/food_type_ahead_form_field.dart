import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/futures/future_api_cache_foods.dart';
import 'package:untare/models/food.dart';

Widget foodTypeAheadFormField(Food? food, GlobalKey<FormBuilderState> formBuilderKey, BuildContext context) {
  final foodTextController = TextEditingController();
  const fieldName = 'food';

  // Set text editors because type ahead field isn't aware of empty string
  if (food != null) {
    foodTextController.text = food.name;
  }

  return FormBuilderTypeAhead<Food>(
    name: fieldName,
    controller: foodTextController,
    initialValue: food,
    selectionToTextTransformer: (food) => food.name,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.food,
    ),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required()
    ]),
    itemBuilder: (context, food) {
      return ListTile(title: Text(food.name));
    },
    suggestionsCallback: (query) async {
      List<Food> foods = await getFoodsFromApiCache(query);
      bool hideOnEqual = false;
      for (var element in foods) {
        (element.name == query) ? hideOnEqual = true : null;
      }
      if (foods.isEmpty || !hideOnEqual) {
        foods.add(Food(id: null, name: query, description: '', onHand: false));
      }
      return foods;
    },
    onSuggestionSelected: (suggestion) {
      foodTextController.text = suggestion.name;
    },
    onSaved: (Food? formFood) {
      Food? newFood = food;

      if (foodTextController.text.isEmpty) {
        // Invalidate empty string because type ahead field isn't aware
        formBuilderKey.currentState!.fields[fieldName]!.didChange(null);
      } else {
        // Overwrite food, if changed in form
        if (food != null && formFood != null) {
          if (food.id != formFood.id || (food.id == null && formFood.id == null)) {
            newFood = Food(id: formFood.id, name: formFood.name, description: formFood.description, onHand: formFood.onHand);
          }
        } else if (formFood == null) {
          if (foodTextController.text != '') {
            newFood = Food(name: foodTextController.text);
          } else {
            newFood = null;
            foodTextController.text = '';
          }
        } else if (food == null) {
          newFood = Food(id: formFood.id, name: formFood.name, description: formFood.description, onHand: formFood.onHand);
        }

        formBuilderKey.currentState!.fields[fieldName]!.didChange(newFood);
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}