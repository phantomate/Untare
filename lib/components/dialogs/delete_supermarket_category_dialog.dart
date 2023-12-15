import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_event.dart';
import 'package:untare/futures/future_api_cache_supermarket_categories.dart';
import 'package:untare/models/supermarket_category.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future deleteSupermarketCategoryDialog(BuildContext context) async {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final ShoppingListBloc shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
  final List<SupermarketCategory> supermarketCategories = await getSupermarketCategoriesFromApiCache();
  final List<DropdownMenuItem> supermarketCategoriesWidgetList =
  supermarketCategories.map((category) => DropdownMenuItem(
    value: category,
    child: Text(category.name),
  )).toList();

  if (!context.mounted) return;

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: FormBuilder(
                key: formBuilderKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Wrap(
                  spacing: 15,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(AppLocalizations.of(context)!.removeSupermarketCategory, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    ),
                    FormBuilderDropdown(
                      name: 'category',
                      items: supermarketCategoriesWidgetList,
                      decoration: InputDecoration(
                          label: Text(AppLocalizations.of(context)!.category)
                      ),
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required()]
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: MaterialButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              formBuilderKey.currentState!.save();

                              if (formBuilderKey.currentState!.validate()) {
                                shoppingListBloc.add(DeleteSupermarketCategory(supermarketCategory: formBuilderKey.currentState!.value['category']));
                                Navigator.pop(dContext);
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.remove)
                        )
                    )
                  ],
                )
            )
        )
    );
  });
}