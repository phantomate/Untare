import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

Widget noteTextFormField(String? note, GlobalKey<FormBuilderState> _formBuilderKey) {
  final fieldName = 'note';

  return FormBuilderTextField(
    name: fieldName,
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

      _formBuilderKey.currentState!.fields[fieldName]!.didChange(newNote);
    },
  );
}