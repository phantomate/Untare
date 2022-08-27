// ignore_for_file: annotate_overrides, overridden_fields

import 'package:hive/hive.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheRecipeService extends CacheService {
  var box = Hive.box('unTaReBox');

  List<Recipe>? getRecipeList(String query, bool random, int page, int pageSize, String? sortOrder) {
    // @todo implement sort
    List<dynamic>? recipes = getQueryablePaginatedList(query, page, pageSize, 'recipes');

    if (recipes != null) {
      return recipes.cast<Recipe>();
    }

    return null;
  }

  upsertRecipeList(List<Recipe> recipes) {
    upsertEntityList(recipes, 'recipes');
  }

  Recipe? getRecipe(int id) {
    List<dynamic>? cache = box.get('recipes');
    List<Recipe>? cacheRecipes = (cache != null) ? cache.cast<Recipe>() : null;

    if (cacheRecipes != null && cacheRecipes.isNotEmpty) {
      int cacheRecipeIndex = cacheRecipes.indexWhere((cacheRecipe) => cacheRecipe.id == id);

      if (cacheRecipeIndex >= 0) {
        return cacheRecipes[cacheRecipeIndex];
      }
    }
    return null;
  }

  upsertRecipe(Recipe recipe) {
    upsertEntity(recipe, 'recipes');
  }

  deleteRecipe(Recipe recipe) {
    deleteEntity(recipe, 'recipes');
  }
}