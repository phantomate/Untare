import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/components/form_fields/food_type_ahead_form_field.dart';
import 'package:tare/components/form_fields/quantity_text_form_field.dart';
import 'package:tare/components/form_fields/unit_type_ahead_form_field.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:tare/models/unit.dart';

Future addShoppingListEntryDialog(BuildContext context) {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  ShoppingListBloc _shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
  bool simpleMode = true;

  return showDialog(context: context, builder: (BuildContext dContext) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: StatefulBuilder(
              builder: (context, setState) {
                return Wrap(
                  spacing: 15,
                  children: [
                    Text('Add to shopping list', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    FormBuilder(
                        key: _formBuilderKey,
                        autovalidateMode: AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FormBuilderSwitch(
                              name: 'switch',
                              title: Text('Simple mode'),
                              onChanged: (bool? value) {
                                setState(() {
                                  simpleMode = value ?? false;
                                });
                              },
                              initialValue: simpleMode,
                              activeColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(
                                  border: InputBorder.none
                              ),
                            ),
                            foodTypeAheadFormField(null, _formBuilderKey),
                            Visibility(
                                visible: !simpleMode,
                                child: Column(
                                  children: [
                                    SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: quantityTextFormField(null, _formBuilderKey),
                                        ),
                                        SizedBox(width: 15),
                                        Flexible(
                                            child: unitTypeAheadFormField(null, _formBuilderKey)
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            SizedBox(height: 15),
                            MaterialButton(
                              color: Theme.of(context).primaryColor,
                              child: Text('Add'),
                              onPressed: () {
                                _formBuilderKey.currentState!.save();
                                if (_formBuilderKey.currentState!.validate()) {
                                  Map<String, dynamic> formBuilderData = _formBuilderKey.currentState!.value;

                                  double amount = 0;
                                  Unit? unit;
                                  if (!simpleMode) {
                                    amount = double.tryParse(formBuilderData['quantity']) ?? 0;
                                    unit = formBuilderData['unit'];
                                  }

                                  ShoppingListEntry newShoppingListEntry =  ShoppingListEntry(food: formBuilderData['food'], unit: unit, amount: amount, checked: false);

                                  _shoppingListBloc.add(CreateShoppingListEntry(shoppingListEntry: newShoppingListEntry));
                                  Navigator.pop(dContext);
                                }
                              },
                            ),
                          ],
                        )
                    )
                  ],
                );
              }),
        )
    );
  });
}