import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/components/form_fields/food_type_ahead_form_field.dart';
import 'package:tare/components/form_fields/quantity_text_form_field.dart';
import 'package:tare/components/form_fields/unit_type_ahead_form_field.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:tare/models/unit.dart';

Future addShoppingListEntryBottomSheet(BuildContext context) {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  ShoppingListBloc _shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
  bool simpleMode = true;

  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        //alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(12),
        child: Wrap(
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  color: Colors.grey[300]
              ),
              child: Text(
                'Add to shopping list',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return FormBuilder(
                      key: _formBuilderKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
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
                            activeColor: primaryColor,
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
                          SizedBox(height: 20),
                          MaterialButton(
                            color: primaryColor,
                            minWidth: double.maxFinite,
                            child: Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
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
                                Navigator.pop(btsContext);
                              }
                            },
                          ),
                        ],
                      )
                  );
                }),
              )
          ],
        ),
      )
  );
}