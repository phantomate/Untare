import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_event.dart';
import 'package:untare/components/form_fields/food_type_ahead_form_field.dart';
import 'package:untare/components/form_fields/quantity_text_form_field.dart';
import 'package:untare/components/form_fields/unit_type_ahead_form_field.dart';
import 'package:untare/models/shopping_list_entry.dart';
import 'package:untare/models/unit.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future addShoppingListEntryDialog(BuildContext context) {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  ShoppingListBloc shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
  bool simpleMode = true;

  return showDialog(context: context, builder: (BuildContext dContext) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: StatefulBuilder(
              builder: (context, setState) {
                return Wrap(
                  spacing: 15,
                  children: [
                    Text(AppLocalizations.of(context)!.addToShoppingList, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    FormBuilder(
                        key: formBuilderKey,
                        autovalidateMode: AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FormBuilderSwitch(
                              name: 'switch',
                              title: Text(AppLocalizations.of(context)!.simpleMode),
                              onChanged: (bool? value) {
                                setState(() {
                                  simpleMode = value ?? false;
                                });
                              },
                              initialValue: simpleMode,
                              activeColor: Theme.of(context).primaryColor,
                              decoration: const InputDecoration(
                                  border: InputBorder.none
                              ),
                            ),
                            foodTypeAheadFormField(null, formBuilderKey, context),
                            Visibility(
                                visible: !simpleMode,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: quantityTextFormField(null, formBuilderKey, context),
                                        ),
                                        const SizedBox(width: 15),
                                        Flexible(
                                            child: unitTypeAheadFormField(null, formBuilderKey, context)
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            const SizedBox(height: 15),
                            MaterialButton(
                              color: Theme.of(context).primaryColor,
                              child: Text(AppLocalizations.of(context)!.add),
                              onPressed: () {
                                formBuilderKey.currentState!.save();
                                if (formBuilderKey.currentState!.validate()) {
                                  Map<String, dynamic> formBuilderData = formBuilderKey.currentState!.value;

                                  double amount = 0;
                                  Unit? unit;
                                  if (!simpleMode) {
                                    amount = double.tryParse(formBuilderData['quantity']) ?? 0;
                                    unit = formBuilderData['unit'];
                                  }

                                  ShoppingListEntry newShoppingListEntry =  ShoppingListEntry(food: formBuilderData['food'], unit: unit, amount: amount, checked: false);

                                  shoppingListBloc.add(CreateShoppingListEntry(shoppingListEntry: newShoppingListEntry));
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