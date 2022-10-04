// ignore_for_file: unused_catch_clause

import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/supermarket_category.dart';
import 'package:untare/services/api/api_supermarket_category.dart';
import 'package:untare/services/cache/cache_shopping_list_service.dart';

Future getSupermarketCategoriesFromApiCache() async {
  final CacheShoppingListService cacheShoppingListService = CacheShoppingListService();
  final ApiSupermarketCategory apiSupermarketCategory = ApiSupermarketCategory();

  List<SupermarketCategory>? cacheCategories = cacheShoppingListService.getSupermarketCategories();

  try {
    Future<List<SupermarketCategory>> categories = apiSupermarketCategory.getSupermarketCategories();
    categories.then((value) => cacheShoppingListService.upsertSupermarketCategories(value));
    return categories;
  } on ApiConnectionException catch (e) {
    if (cacheCategories != null && cacheCategories.isNotEmpty) {
      return cacheCategories;
    }
  }
}