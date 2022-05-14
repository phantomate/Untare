import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

Widget noteTextFormField(String? note, GlobalKey<FormBuilderState> _formBuilderKey, {int? index, dynamicKey}) {
  final fieldName = 'note' + ((index != null) ? index.toString() : '');

  return FormBuilderTextField(
    name: fieldName,
    key: dynamicKey,
    initialValue: note,
    decoration: InputDecoration(
        labelText: 'Note',
    ),
    onSaved: (String? formNote) {
      String? newNote = note;

      // Overwrite note, if changed in form
      if (note != formNote) {
        newNote = formNote ?? '';
      }

      // If we have a dynamic key the form field is generated dynamically and therefore we have to use an other method
      if (dynamicKey != null) {
        _formBuilderKey.currentState!.setInternalFieldValue(fieldName, newNote, isSetState: true);
      } else {
        _formBuilderKey.currentState!.fields[fieldName]!.didChange(newNote);
      }
    },
  );
}