import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/models/food.dart';
import 'package:tare/services/api/api_food.dart';

Widget foodTypeAheadFormField(Food? food, GlobalKey<FormBuilderState> _formBuilderKey) {
  final _foodTextController = TextEditingController();
  final ApiFood _apiFood = ApiFood();
  final fieldName = 'food';

  // Set text editors because type ahead field isn't aware of empty string
  if (food != null) {
    _foodTextController.text = food.name;
  }

  return FormBuilderTypeAhead<Food>(
    name: fieldName,
    controller: _foodTextController,
    initialValue: food,
    selectionToTextTransformer: (food) => food.name,
    decoration: InputDecoration(
      labelText: 'Food',
    ),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required()
    ]),
    itemBuilder: (context, food) {
      return ListTile(title: Text(food.name));
    },
    suggestionsCallback: (query) async {
      List<Food> foods = await _apiFood.getFoods(query, 1, 25);
      bool hideOnEqual = false;
      foods.forEach((element) => (element.name == query) ? hideOnEqual = true : null);
      if (foods.isEmpty || !hideOnEqual) {
        foods.add(Food(id: null, name: query, description: '', onHand: false));
      }
      return foods;
    },
    onSuggestionSelected: (suggestion) {
      _foodTextController.text = suggestion.name;
    },
    onSaved: (Food? formFood) {
      Food? newFood = food;

      if (_foodTextController.text.isEmpty) {
        // Invalidate empty string because type ahead field isn't aware
        _formBuilderKey.currentState!.fields[fieldName]!.didChange(null);
      } else {
        // Overwrite food, if changed in form
        if (food != null && formFood != null) {
          if (food.id != formFood.id) {
            newFood = Food(id: formFood.id, name: formFood.name, description: formFood.description, onHand: formFood.onHand);
          }
        } else if (formFood == null) {
          newFood = null;
          _foodTextController.text = '';
        } else if (food == null) {
          newFood = Food(id: formFood.id, name: formFood.name, description: formFood.description, onHand: formFood.onHand);
        }

        _formBuilderKey.currentState!.fields[fieldName]!.didChange(newFood);
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}