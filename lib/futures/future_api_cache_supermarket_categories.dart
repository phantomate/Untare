import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:tare/services/api/api_supermarket_category.dart';
import 'package:tare/services/cache/cache_shopping_list_service.dart';

Future getSupermarketCategoriesFromApiCache() async {
  final CacheShoppingListService _cacheShoppingListService = CacheShoppingListService();
  final ApiSupermarketCategory _apiSupermarketCategory = ApiSupermarketCategory();

  List<SupermarketCategory>? cacheCategories = _cacheShoppingListService.getSupermarketCategories();

  if (cacheCategories != null) {
    return cacheCategories;
  }

  try {
    Future<List<SupermarketCategory>> categories = _apiSupermarketCategory.getSupermarketCategories();
    categories.then((value) => _cacheShoppingListService.upsertSupermarketCategories(value));
    return categories;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}