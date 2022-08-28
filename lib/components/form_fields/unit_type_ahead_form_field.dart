import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:untare/futures/future_api_cache_units.dart';
import 'package:untare/models/unit.dart';

Widget unitTypeAheadFormField(Unit? unit, GlobalKey<FormBuilderState> formBuilderKey, BuildContext context) {
  final unitTextController = TextEditingController();
  const fieldName = 'unit';

  // Set text editors because type ahead field isn't aware of empty string
  if (unit != null) {
    unitTextController.text = unit.name;
  }
  
  return FormBuilderTypeAhead<Unit>(
    name: fieldName,
    controller: unitTextController,
    initialValue: unit,
    selectionToTextTransformer: (unit) => unit.name,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.unit
    ),
    itemBuilder: (context, unit) {
      return ListTile(title: Text(unit.name));
    },
    suggestionsCallback: (query) async {
      List<Unit> units = await getUnitsFromApiCache(query);
      bool hideOnEqual = false;
      for (var element in units) {
        (element.name == query) ? hideOnEqual = true : null;
      }
      if (units.isEmpty || !hideOnEqual) {
        units.add(Unit(id: null, name: query, description: ''));
      }
      return units;
    },
    onSuggestionSelected: (suggestion) {
      unitTextController.text = suggestion.name;
    },
    onSaved: (Unit? formUnit) {
      Unit? newUnit = unit;
      
      if (unitTextController.text.isEmpty) {
        // Invalidate empty string because type ahead field isn't aware
        formBuilderKey.currentState!.fields[fieldName]!.didChange(null);
      } else {
        // Overwrite unit, if changed in form
        if (unit != null && formUnit != null) {
          if (unit.id != formUnit.id || (unit.id == null && formUnit.id == null)) {
            newUnit = Unit(id: formUnit.id, name: formUnit.name, description: formUnit.description);
          }
        } else if (formUnit== null) {
          newUnit = null;
          unitTextController.text = '';
        } else if (unit == null) {
          newUnit = Unit(id: formUnit.id, name: formUnit.name, description: formUnit.description);
        }

        formBuilderKey.currentState!.fields[fieldName]!.didChange(newUnit);
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}