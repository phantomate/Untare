import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:tare/futures/future_api_cache_units.dart';
import 'package:tare/models/unit.dart';

Widget unitTypeAheadFormField(Unit? unit, GlobalKey<FormBuilderState> _formBuilderKey, BuildContext context) {
  final _unitTextController = TextEditingController();
  final fieldName = 'unit';

  // Set text editors because type ahead field isn't aware of empty string
  if (unit != null) {
    _unitTextController.text = unit.name;
  }
  
  return FormBuilderTypeAhead<Unit>(
    name: fieldName,
    controller: _unitTextController,
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
      units.forEach((element) => (element.name == query) ? hideOnEqual = true : null);
      if (units.isEmpty || !hideOnEqual) {
        units.add(Unit(id: null, name: query, description: ''));
      }
      return units;
    },
    onSuggestionSelected: (suggestion) {
      _unitTextController.text = suggestion.name;
    },
    onSaved: (Unit? formUnit) {
      Unit? newUnit = unit;
      
      if (_unitTextController.text.isEmpty) {
        // Invalidate empty string because type ahead field isn't aware
        _formBuilderKey.currentState!.fields[fieldName]!.didChange(null);
      } else {
        // Overwrite unit, if changed in form
        if (unit != null && formUnit != null) {
          if (unit.id != formUnit.id) {
            newUnit = Unit(id: formUnit.id, name: formUnit.name, description: formUnit.description);
          }
        } else if (formUnit== null) {
          newUnit = null;
          _unitTextController.text = '';
        } else if (unit == null) {
          newUnit = Unit(id: formUnit.id, name: formUnit.name, description: formUnit.description);
        }

        _formBuilderKey.currentState!.fields[fieldName]!.didChange(newUnit);
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}