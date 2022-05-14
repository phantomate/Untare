import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:tare/services/api/api_supermarket_category.dart';

Widget supermarketCategoryTypeAheadFormField(SupermarketCategory? supermarketCategory, GlobalKey<FormBuilderState> _formBuilderKey) {
  final _categoryTextController = TextEditingController();
  final ApiSupermarketCategory _apiSupermarketCategory = ApiSupermarketCategory();
  List<SupermarketCategory> _superMarketCategories = [];

  if (supermarketCategory != null) {
    _categoryTextController.text = supermarketCategory.name;
  }
  
  return FormBuilderTypeAhead<SupermarketCategory>(
    name: 'category',
    controller: _categoryTextController,
    initialValue: supermarketCategory,
    selectionToTextTransformer: (category) => category.name,
    decoration: InputDecoration(
      labelText: 'Category'
    ),
    itemBuilder: (context, category) {
      return ListTile(title: Text(category.name));
    },
    suggestionsCallback: (query) async {
      if (_superMarketCategories.isEmpty) {
        _superMarketCategories = await _apiSupermarketCategory.getSupermarketCategories();
      }

      List<SupermarketCategory> supermarketCategoriesByQuery = [];
      _superMarketCategories.forEach((element) {
        if (element.name.contains(query)) {
          supermarketCategoriesByQuery.add(element);
        }
      });

      bool hideOnEqual = false;
      _superMarketCategories.forEach((element) => (element.name == query) ? hideOnEqual = true : null);


      if (query != '' && (supermarketCategoriesByQuery.isEmpty || !hideOnEqual)) {
        supermarketCategoriesByQuery.add(SupermarketCategory(name: query));
      }

      return supermarketCategoriesByQuery;
    },
    onSuggestionSelected: (suggestion) {
      _categoryTextController.text = suggestion.name;
    },
    onSaved: (SupermarketCategory? formCategory) {
      SupermarketCategory? newCategory = supermarketCategory;
      
      // Invalidate empty string because type ahead field isn't aware
      if (_categoryTextController.text.isEmpty) {
        _formBuilderKey.currentState!.fields['category']!.didChange(null);
      } else {
        // Overwrite category, if changed in form
        if (supermarketCategory != null && formCategory != null) {
          if (supermarketCategory.id != formCategory.id) {
            newCategory = SupermarketCategory(id: formCategory.id, name: formCategory.name, description: formCategory.description);
          }
        } else if (formCategory== null) {
          newCategory = null;
          _categoryTextController.text = '';
        } else if (supermarketCategory == null) {
          newCategory = SupermarketCategory(id: formCategory.id, name: formCategory.name, description: formCategory.description);
        }

        _formBuilderKey.currentState!.fields['category']!.didChange(newCategory);
      }
    },
    hideOnEmpty: true,
    hideSuggestionsOnKeyboardHide: true,
    hideOnLoading: true,
  );
}