import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/models/food.dart';
import 'package:tare/services/api/api_food.dart';

Widget foodTypeAheadFormField(Food? food, GlobalKey<FormBuilderState> _formBuilderKey, {int? index, dynamicKey}) {
  final _foodTextController = TextEditingController();
  final ApiFood _apiFood = ApiFood();
  final fieldName = 'food' + ((index != null) ? index.toString() : '');

  // Set text editors because type ahead field isn't aware of empty string
  if (food != null) {
    _foodTextController.text = food.name;
  }

  return FormBuilderTypeAhead<Food>(
    name: fieldName,
    key: dynamicKey,
    controller: _foodTextController,
    initialValue: food,
    selectionToTextTransformer: (food) => food.name,
    decoration: const InputDecoration(
      labelText: 'Food',
      labelStyle: TextStyle(
        color: Colors.black26,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.all(10),
      border: OutlineInputBorder(),
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
        if (dynamicKey != null)  {
          _formBuilderKey.currentState!.setInternalFieldValue(fieldName, null, isSetState: true);
          // Do own validation, because the package validation doesn't work on dynamically generated fields
          dynamicKey.currentState!.invalidate('');
        } else {
          _formBuilderKey.currentState!.fields[fieldName]!.didChange(null);
        }
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

        // If we have a dynamic key the form field is generated dynamically and therefore we have to use an other method
        if (dynamicKey != null) {
          if (newFood == null) {
            // Do own validation, because the package validation doesn't work on dynamically generated fields
            dynamicKey.currentState!.invalidate('');
          }
          _formBuilderKey.currentState!.setInternalFieldValue(fieldName, newFood, isSetState: true);
        } else {
          _formBuilderKey.currentState!.fields[fieldName]!.didChange(newFood);
        }
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}