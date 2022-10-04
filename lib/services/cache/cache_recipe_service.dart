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

  upsertRecipeList(List<Recipe> recipes, String query, bool random, int page, int pageSize, String? sortOrder) {
    List<dynamic>? cacheEntities = box.get('recipes');

    if (cacheEntities != null && cacheEntities.isNotEmpty) {
      for (var entity in recipes) {
        int cacheEntityIndex = cacheEntities.indexWhere((cacheEntity) => cacheEntity.id == entity.id);

        // If we found the entity in cache entities, overwrite data, if not add entity
        if (cacheEntityIndex >= 0) {
          // Keep steps from recipe, because we get empty step list from recipe list call
          entity = entity.copyWith(steps: cacheEntities[cacheEntityIndex].steps);

          cacheEntities[cacheEntityIndex] = entity;
        } else {
          cacheEntities.add(entity);
        }
      }
    } else {
      cacheEntities = [];
      cacheEntities.addAll(recipes);
    }

    box.put('recipes', cacheEntities);

    // After upsert, check if we have to delete entries
    List<Recipe>? cacheEntitiesForDeletion = getRecipeList(query, random, page, pageSize, sortOrder);

    if (cacheEntitiesForDeletion != null) {
      cacheEntitiesForDeletion.removeWhere((element) {
        return recipes.indexWhere((e) => e.id == element.id) >= 0;
      });

      for (var entity in cacheEntitiesForDeletion) {
        deleteRecipe(entity);
      }
    }
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