// ignore_for_file: unused_catch_clause

import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/services/api/api_recipe.dart';
import 'package:untare/services/cache/cache_recipe_service.dart';

Future getRecipesFromApiCache(String query) async {
  final CacheRecipeService cacheRecipeService = CacheRecipeService();
  final ApiRecipe apiRecipe = ApiRecipe();

  List<Recipe>? cacheRecipes = cacheRecipeService.getRecipeList(query, false, 1, 25, null);

  if (cacheRecipes != null && cacheRecipes.isNotEmpty) {
    return cacheRecipes;
  }

  try {
    Future<List<Recipe>> recipes = apiRecipe.getRecipeList(query, false, 1, 25, null);
    recipes.then((value) => cacheRecipeService.upsertRecipeList(value));
    return recipes;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}