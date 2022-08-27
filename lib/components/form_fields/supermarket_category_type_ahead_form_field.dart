import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:untare/futures/future_api_cache_supermarket_categories.dart';
import 'package:untare/models/supermarket_category.dart';

Widget supermarketCategoryTypeAheadFormField(SupermarketCategory? supermarketCategory, GlobalKey<FormBuilderState> formBuilderKey, BuildContext context) {
  final categoryTextController = TextEditingController();

  if (supermarketCategory != null) {
    categoryTextController.text = supermarketCategory.name;
  }
  
  return FormBuilderTypeAhead<SupermarketCategory>(
    name: 'category',
    controller: categoryTextController,
    initialValue: supermarketCategory,
    selectionToTextTransformer: (category) => category.name,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context)!.category
    ),
    itemBuilder: (context, category) {
      return ListTile(title: Text(category.name));
    },
    suggestionsCallback: (query) async {
      List<SupermarketCategory> superMarketCategories = await getSupermarketCategoriesFromApiCache();

      List<SupermarketCategory> supermarketCategoriesByQuery = [];
      for (var element in superMarketCategories) {
        if (element.name.toLowerCase().contains(query.toLowerCase())) {
          supermarketCategoriesByQuery.add(element);
        }
      }

      bool hideOnEqual = false;
      for (var element in superMarketCategories) {
        (element.name.toLowerCase() == query.toLowerCase()) ? hideOnEqual = true : null;
      }

      if (query != '' && (supermarketCategoriesByQuery.isEmpty || !hideOnEqual)) {
        supermarketCategoriesByQuery.add(SupermarketCategory(name: query));
      }

      return supermarketCategoriesByQuery;
    },
    onSuggestionSelected: (suggestion) {
      categoryTextController.text = suggestion.name;
    },
    onSaved: (SupermarketCategory? formCategory) {
      SupermarketCategory? newCategory = supermarketCategory;
      
      // Invalidate empty string because type ahead field isn't aware
      if (categoryTextController.text.isEmpty) {
        formBuilderKey.currentState!.fields['category']!.didChange(null);
      } else {
        // Overwrite category, if changed in form
        if (supermarketCategory != null && formCategory != null) {
          if (supermarketCategory.id != formCategory.id) {
            newCategory = SupermarketCategory(id: formCategory.id, name: formCategory.name, description: formCategory.description);
          }
        } else if (formCategory== null) {
          newCategory = null;
          categoryTextController.text = '';
        } else if (supermarketCategory == null) {
          newCategory = SupermarketCategory(id: formCategory.id, name: formCategory.name, description: formCategory.description);
        }

        formBuilderKey.currentState!.fields['category']!.didChange(newCategory);
      }
    },
    hideOnEmpty: true,
    hideSuggestionsOnKeyboardHide: true,
    hideOnLoading: true,
  );
}