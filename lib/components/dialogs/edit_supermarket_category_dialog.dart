import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_event.dart';
import 'package:untare/futures/future_api_cache_supermarket_categories.dart';
import 'package:untare/models/supermarket_category.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future editSupermarketCategoryDialog(BuildContext context) async {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final ShoppingListBloc shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
  final List<SupermarketCategory> supermarketCategories = await getSupermarketCategoriesFromApiCache();
  final List<DropdownMenuItem> supermarketCategoriesWidgetList =
    supermarketCategories.map((category) => DropdownMenuItem(
      value: category,
      child: Text(category.name),
    )).toList();
  bool isVisible = false;

  if (!context.mounted) return;

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
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(AppLocalizations.of(context)!.editSupermarketCategories, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
                    onChanged: (dynamic value) {
                      if (!isVisible) {
                        setState(() {
                          isVisible = true;
                        });
                      }
                    },
                  ),
                  Visibility(
                    visible: isVisible,
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                                label: Text(AppLocalizations.of(context)!.newCategoryName)
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.max(128),
                            ]),
                          )
                        ],
                      )
                  ),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: MaterialButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: isVisible ? () {
                        formBuilderKey.currentState!.save();

                        if (formBuilderKey.currentState!.validate()) {
                          SupermarketCategory category = formBuilderKey.currentState!.value['category'];
                          String newName = formBuilderKey.currentState!.value['name'];

                          SupermarketCategory newSupermarketCategory = category.copyWith(name: newName);
                          shoppingListBloc.add(UpdateSupermarketCategory(supermarketCategory: newSupermarketCategory));
                          Navigator.pop(dContext);
                        }
                      } : null,
                      child: Text(AppLocalizations.of(context)!.edit)
                    )
                  )
                ],
              );
            }
          )
        )
      )
    );
  });
}