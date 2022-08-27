import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

Widget noteTextFormField(String? note, GlobalKey<FormBuilderState> formBuilderKey, BuildContext context) {
  const fieldName = 'note';

  return FormBuilderTextField(
    name: fieldName,
    initialValue: note,
    decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.note,
    ),
    onSaved: (String? formNote) {
      String? newNote = note;

      // Overwrite note, if changed in form
      if (note != formNote) {
        newNote = formNote ?? '';
      }

      formBuilderKey.currentState!.fields[fieldName]!.didChange(newNote);
    },
  );
}