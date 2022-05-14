import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:tare/models/unit.dart';
import 'package:tare/services/api/api_unit.dart';

Widget unitTypeAheadFormField(Unit? unit, GlobalKey<FormBuilderState> _formBuilderKey, {int? index, dynamicKey}) {
  final _unitTextController = TextEditingController();
  final ApiUnit _apiUnit = ApiUnit();
  final fieldName = 'unit' + ((index != null) ? index.toString() : '');

  if (unit != null) {
    _unitTextController.text = unit.name;
  }
  
  return FormBuilderTypeAhead<Unit>(
    name: fieldName,
    controller: _unitTextController,
    key: dynamicKey,
    initialValue: unit,
    selectionToTextTransformer: (unit) => unit.name,
    decoration: const InputDecoration(
      labelText: 'Unit'
    ),
    itemBuilder: (context, unit) {
      return ListTile(title: Text(unit.name));
    },
    suggestionsCallback: (query) async {
      List<Unit> units = await _apiUnit.getUnits(query, 1, 25);
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
        if (dynamicKey != null)  {
          _formBuilderKey.currentState!.setInternalFieldValue(fieldName, null, isSetState: true);
          // Do own validation, because the package validation doesn't work on dynamically generated fields
          dynamicKey.currentState!.invalidate('');
        } else {
          _formBuilderKey.currentState!.fields[fieldName]!.didChange(null);
        }
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

        // If we have a dynamic key the form field is generated dynamically and therefore we have to use an other method
        if (dynamicKey != null) {
          if (newUnit == null) {
            // Do own validation, because the package validation doesn't work on dynamically generated fields
            dynamicKey.currentState!.invalidate('');
          }
          _formBuilderKey.currentState!.setInternalFieldValue(fieldName, newUnit, isSetState: true);
        } else {
          _formBuilderKey.currentState!.fields[fieldName]!.didChange(newUnit);
        }
      }
    },
    hideOnEmpty: true,
    hideOnLoading: true,
    hideSuggestionsOnKeyboardHide: true,
  );
}