import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:tare/futures/future_api_cache_supermarket_categories.dart';
import 'package:tare/models/supermarket_category.dart';

Widget supermarketCategoryTypeAheadFormField(SupermarketCategory? supermarketCategory, GlobalKey<FormBuilderState> _formBuilderKey, BuildContext context) {
  final _categoryTextController = TextEditingController();

  if (supermarketCategory != null) {
    _categoryTextController.text = supermarketCategory.name;
  }
  
  return FormBuilderTypeAhead<SupermarketCategory>(
    name: 'category',
    controller: _categoryTextController,
    initialValue: supermarketCategory,
    selectionToTextTransformer: (category) => category.name,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.category
    ),
    itemBuilder: (context, category) {
      return ListTile(title: Text(category.name));
    },
    suggestionsCallback: (query) async {
      List<SupermarketCategory> _superMarketCategories = await getSupermarketCategoriesFromApiCache();

      List<SupermarketCategory> supermarketCategoriesByQuery = [];
      _superMarketCategories.forEach((element) {
        if (element.name.toLowerCase().contains(query.toLowerCase())) {
          supermarketCategoriesByQuery.add(element);
        }
      });

      bool hideOnEqual = false;
      _superMarketCategories.forEach((element) => (element.name.toLowerCase() == query.toLowerCase()) ? hideOnEqual = true : null);

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