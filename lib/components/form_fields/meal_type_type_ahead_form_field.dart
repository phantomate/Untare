import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/futures/future_api_cache_meal_types.dart';
import 'package:untare/models/meal_type.dart';

Widget mealTypeTypeAheadFieldForm(MealType? mealType, GlobalKey<FormBuilderState> formBuilderKey, BuildContext context) {
  final mealTypeTextController = TextEditingController();

  if (mealType != null) {
    mealTypeTextController.text = mealType.name;
  }
  
  return FormBuilderTypeAhead<MealType>(
    name: 'mealType',
    initialValue: mealType,
    controller: mealTypeTextController,
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
      List<MealType> mealTypeList = await getMealTypesFromApiCache();

      List<MealType> mealTypeListByQuery = [];
      for (var element in mealTypeList) {
        if (element.name.toLowerCase().contains(query.toLowerCase())) {
          mealTypeListByQuery.add(element);
        }
      }

      bool hideOnEqual = false;
      for (var element in mealTypeList) {
        (element.name.toLowerCase() == query.toLowerCase()) ? hideOnEqual = true : null;
      }

      if (query != '' && (mealTypeListByQuery.isEmpty || !hideOnEqual)) {
        mealTypeListByQuery.add(MealType(name: query, defaultType: false, order: 0, createdBy: 1));
      }

      return mealTypeListByQuery;
    },
    onSuggestionSelected: (suggestion) {
      mealTypeTextController.text = suggestion.name;
    },
    onSaved: (MealType? formMealType) {
      MealType? newMealType = mealType;

      // Invalidate empty string because type ahead field isn't aware
      if (mealTypeTextController.text.isEmpty) {
        formBuilderKey.currentState!.fields['mealType']!.didChange(null);
      } else {
        // Overwrite meal type, if changed in form
        if (mealType != null && formMealType != null) {
          if (mealType.id != formMealType.id) {
            newMealType = MealType(id: formMealType.id, name: formMealType.name, defaultType: formMealType.defaultType, order: formMealType.order, createdBy: formMealType.createdBy);
          }
        } else if (formMealType== null) {
          newMealType = null;
          mealTypeTextController.text = '';
        } else if (mealType == null) {
          newMealType = MealType(id: formMealType.id, name: formMealType.name, defaultType: formMealType.defaultType, order: formMealType.order, createdBy: formMealType.createdBy);
        }

        formBuilderKey.currentState!.fields['mealType']!.didChange(newMealType);
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}