import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/extensions/double_extension.dart';

Widget quantityTextFormField(double? amount, GlobalKey<FormBuilderState> _formBuilderKey, {int? index, dynamicKey}) {
  final fieldName = 'quantity' + ((index != null) ? index.toString() : '');

  return FormBuilderTextField(
    name: fieldName,
    key: dynamicKey,
    initialValue: (amount != null ) ? amount.toFormattedString() : null,
    decoration: InputDecoration(
      labelText: 'Quantity'
    ),
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.numeric(),
    ]),
    onSaved: (String? formAmount) {
      double newAmount = amount ?? 0;
      double formAmountDouble = double.tryParse(formAmount ?? '') ?? 0;

      // Overwrite amount, if changed in form
      if (newAmount.compareTo(formAmountDouble) != 0) {
        newAmount = formAmountDouble;
      } else if (newAmount.compareTo(formAmountDouble) == 0) {
        newAmount = newAmount;
      }

      // If we have a dynamic key the form field is generated dynamically and therefore we have to use an other method
      if (dynamicKey != null) {
        _formBuilderKey.currentState!.setInternalFieldValue(fieldName, newAmount.toFormattedString(), isSetState: true);
      } else {
        _formBuilderKey.currentState!.fields[fieldName]!.didChange(newAmount.toFormattedString());
      }
    },
  );
}