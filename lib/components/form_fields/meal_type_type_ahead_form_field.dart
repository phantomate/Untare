import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/models/meal_type.dart';
import 'package:tare/services/api/api_meal_type.dart';

Widget mealTypeTypeAheadFieldForm(MealType? mealType, GlobalKey<FormBuilderState> _formBuilderKey, BuildContext context) {
  final ApiMealType _apiMealType = ApiMealType();
  final _mealTypeTextController = TextEditingController();
  List<MealType> _mealTypeList = [];

  if (mealType != null) {
    _mealTypeTextController.text = mealType.name;
  }
  
  return FormBuilderTypeAhead<MealType>(
    name: 'mealType',
    initialValue: mealType,
    controller: _mealTypeTextController,
    selectionToTextTransformer: (mealType) => mealType.name,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.mealType,
    ),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required()
    ]),
    itemBuilder: (context, mealType) {
      return ListTile(title: Text(mealType.name));
    },
    suggestionsCallback: (query) async {
      if (_mealTypeList.isEmpty) {
        _mealTypeList = await _apiMealType.getMealTypeList();
      }

      List<MealType> mealTypeListByQuery = [];
      _mealTypeList.forEach((element) {
        if (element.name.contains(query)) {
          mealTypeListByQuery.add(element);
        }
      });

      bool hideOnEqual = false;
      _mealTypeList.forEach((element) => (element.name == query) ? hideOnEqual = true : null);


      if (query != '' && (mealTypeListByQuery.isEmpty || !hideOnEqual)) {
        mealTypeListByQuery.add(MealType(name: query, defaultType: false, order: 0, createdBy: 1));
      }

      return mealTypeListByQuery;
    },
    onSuggestionSelected: (suggestion) {
      _mealTypeTextController.text = suggestion.name;
    },
    onSaved: (MealType? formMealType) {
      MealType? newMealType = mealType;

      // Invalidate empty string because type ahead field isn't aware
      if (_mealTypeTextController.text.isEmpty) {
        _formBuilderKey.currentState!.fields['mealType']!.didChange(null);
      } else {
        // Overwrite meal type, if changed in form
        if (mealType != null && formMealType != null) {
          if (mealType.id != formMealType.id) {
            newMealType = MealType(id: formMealType.id, name: formMealType.name, defaultType: formMealType.defaultType, order: formMealType.order, createdBy: formMealType.createdBy);
          }
        } else if (formMealType== null) {
          newMealType = null;
          _mealTypeTextController.text = '';
        } else if (mealType == null) {
          newMealType = MealType(id: formMealType.id, name: formMealType.name, defaultType: formMealType.defaultType, order: formMealType.order, createdBy: formMealType.createdBy);
        }

        _formBuilderKey.currentState!.fields['mealType']!.didChange(newMealType);
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}