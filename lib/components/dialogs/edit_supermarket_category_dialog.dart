import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:tare/services/api/api_supermarket_category.dart';

Future editSupermarketCategoryDialog(BuildContext context) async {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  final ShoppingListBloc _shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
  final ApiSupermarketCategory _apiSupermarketCategory = ApiSupermarketCategory();
  final List<SupermarketCategory> supermarketCategories = await _apiSupermarketCategory.getSupermarketCategories();
  final List<DropdownMenuItem> supermarketCategoriesWidgetList =
    supermarketCategories.map((category) => DropdownMenuItem(
      value: category,
      child: Text(category.name),
    )).toList();
  bool isVisible = false;

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
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text('Edit supermarket category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  FormBuilderDropdown(
                    name: 'category',
                    allowClear: true,
                    items: supermarketCategoriesWidgetList,
                    decoration: InputDecoration(
                        label: Text('Category')
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
                          SizedBox(height: 15),
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                                label: Text('New name')
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.max(128),
                            ]),
                          )
                        ],
                      )
                  ),
                  SizedBox(height: 15),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: MaterialButton(
                      color: primaryColor,
                      onPressed: isVisible ? () {
                        _formBuilderKey.currentState!.save();

                        if (_formBuilderKey.currentState!.validate()) {
                          SupermarketCategory category = _formBuilderKey.currentState!.value['category'];
                          String newName = _formBuilderKey.currentState!.value['name'];

                          SupermarketCategory newSupermarketCategory = category.copyWith(name: newName);
                          _shoppingListBloc.add(UpdateSupermarketCategory(supermarketCategory: newSupermarketCategory));
                          Navigator.pop(dContext);
                        }
                      } : null,
                      child: Text('Edit')
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