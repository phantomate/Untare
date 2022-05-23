import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/components/form_fields/food_type_ahead_form_field.dart';
import 'package:tare/components/form_fields/quantity_text_form_field.dart';
import 'package:tare/components/form_fields/supermarket_category_type_ahead_form_field.dart';
import 'package:tare/components/form_fields/unit_type_ahead_form_field.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/food.dart';
import 'package:tare/models/shopping_list_entry.dart';

Future editShoppingListEntryDialog(BuildContext context, ShoppingListEntry shoppingListEntry) {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  ShoppingListBloc _shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: FormBuilder(
                key: _formBuilderKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: StatefulBuilder(
                    builder: (context, setState) {
                      return Wrap(
                        spacing: 15,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text('Edit shopping list entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          foodTypeAheadFormField(shoppingListEntry.food, _formBuilderKey),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Flexible(
                                child: quantityTextFormField(shoppingListEntry.amount, _formBuilderKey),
                              ),
                              SizedBox(width: 15),
                              Flexible(
                                  child: unitTypeAheadFormField(shoppingListEntry.unit, _formBuilderKey)
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          supermarketCategoryTypeAheadFormField((shoppingListEntry.food != null) ? shoppingListEntry.food!.supermarketCategory : null, _formBuilderKey),
                          SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: primaryColor,
                                  onPressed: () {
                                    _formBuilderKey.currentState!.save();
                                    if (_formBuilderKey.currentState!.validate()) {
                                      Map<String, dynamic> formBuilderData = _formBuilderKey.currentState!.value;
                                      print(_formBuilderKey.currentState!.value);
                                      double amount = double.tryParse(formBuilderData['quantity']) ?? 0;

                                      // Set supermarket category on food
                                      Food foodWithNewCategory = formBuilderData['food'].copyWith(supermarketCategory: formBuilderData['category']);

                                      // Value processing is located in on save method of every form item
                                      ShoppingListEntry entry = shoppingListEntry.copyWith(food: foodWithNewCategory, amount: amount, unit: formBuilderData['unit']);
                                      _shoppingListBloc.add(UpdateShoppingListEntry(shoppingListEntry: entry));
                                      Navigator.pop(dContext);
                                    }
                                  },
                                  child: Text('Save')
                              )
                          )
                        ]
                      );
                    }
                )
            )
        )
    );
  });
}