import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/services/api/api_recipe.dart';
import 'package:tare/services/cache/cache_recipe_service.dart';

Future getRecipesFromApiCache(String query) async {
  final CacheRecipeService _cacheRecipeService = CacheRecipeService();
  final ApiRecipe _apiRecipe = ApiRecipe();

  List<Recipe>? cacheRecipes = _cacheRecipeService.getRecipeList(query, false, 1, 25, null);

  if (cacheRecipes != null) {
    return cacheRecipes;
  }

  try {
    Future<List<Recipe>> recipes = _apiRecipe.getRecipeList(query, false, 1, 25, null);
    recipes.then((value) => _cacheRecipeService.upsertRecipeList(value));
    return recipes;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}