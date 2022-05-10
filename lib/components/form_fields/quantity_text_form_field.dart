import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

Widget quantityTextFormField(double? amount, GlobalKey<FormBuilderState> _formBuilderKey, {int? index, dynamicKey}) {
  final fieldName = 'quantity' + ((index != null) ? index.toString() : '');

  return FormBuilderTextField(
    name: fieldName,
    key: dynamicKey,
    initialValue: (amount != null ) ? amount.toString() : null,
    decoration: InputDecoration(
      labelText: 'Quantity',
      labelStyle: TextStyle(
        color: Colors.black26,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.all(10),
      border: OutlineInputBorder(),
    ),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.numeric(),
    ]),
    onSaved: (String? formAmount) {
      double? newAmount = amount;

      // Overwrite amount, if changed in form
      if (amount.toString() != formAmount) {
        newAmount = (!['', null].contains(formAmount)) ? double.tryParse(formAmount!) : 0;
      } else if (amount.toString() == formAmount) {
        newAmount = amount;
      }
      newAmount = newAmount ?? 0;

      // If we have a dynamic key the form field is generated dynamically and therefore we have to use an other method
      if (dynamicKey != null) {
        _formBuilderKey.currentState!.setInternalFieldValue(fieldName, newAmount.toString(), isSetState: true);
      } else {
        _formBuilderKey.currentState!.fields[fieldName]!.didChange(newAmount.toString());
      }
    },
  );
}