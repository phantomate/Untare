import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_event.dart';
import 'package:untare/components/form_fields/food_type_ahead_form_field.dart';
import 'package:untare/components/form_fields/quantity_text_form_field.dart';
import 'package:untare/components/form_fields/supermarket_category_type_ahead_form_field.dart';
import 'package:untare/components/form_fields/unit_type_ahead_form_field.dart';
import 'package:untare/models/food.dart';
import 'package:untare/models/shopping_list_entry.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future editShoppingListEntryDialog(BuildContext context, ShoppingListEntry shoppingListEntry) {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  ShoppingListBloc shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: FormBuilder(
                key: formBuilderKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: StatefulBuilder(
                    builder: (context, setState) {
                      return Wrap(
                        spacing: 15,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(AppLocalizations.of(context)!.editShoppingListEntry, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          foodTypeAheadFormField(shoppingListEntry.food, formBuilderKey, context),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Flexible(
                                child: quantityTextFormField(shoppingListEntry.amount, formBuilderKey, context),
                              ),
                              const SizedBox(width: 15),
                              Flexible(
                                  child: unitTypeAheadFormField(shoppingListEntry.unit, formBuilderKey, context)
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          supermarketCategoryTypeAheadFormField((shoppingListEntry.food != null) ? shoppingListEntry.food!.supermarketCategory : null, formBuilderKey, context),
                          const SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    formBuilderKey.currentState!.save();
                                    if (formBuilderKey.currentState!.validate()) {
                                      Map<String, dynamic> formBuilderData = formBuilderKey.currentState!.value;
                                      double amount = double.tryParse(formBuilderData['quantity']) ?? 0;

                                      // Set supermarket category on food
                                      Food foodWithNewCategory = formBuilderData['food'].copyWith(supermarketCategory: formBuilderData['category']);

                                      // Value processing is located in on save method of every form item
                                      ShoppingListEntry entry = shoppingListEntry.copyWith(food: foodWithNewCategory, amount: amount, unit: formBuilderData['unit']);
                                      shoppingListBloc.add(UpdateShoppingListEntry(shoppingListEntry: entry));
                                      Navigator.pop(dContext);
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.edit)
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