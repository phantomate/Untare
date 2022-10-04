// ignore_for_file: overridden_fields, annotate_overrides

import 'package:hive/hive.dart';
import 'package:untare/models/food.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheFoodService extends CacheService {
  var box = Hive.box('unTaReBox');

  List<Food>? getFoods(String query, int page, int pageSize) {
    List<dynamic>? foods = getQueryablePaginatedList(query, page, pageSize, 'foods');

    if (foods != null) {
      return foods.cast<Food>();
    }

    return null;
  }

  upsertFoods(List<Food> foods, String query, int page, int pageSize) {
    upsertEntityList(foods, 'foods');

    // After upsert, check if we have to delete entries
    List<Food>? cacheEntitiesForDeletion = getFoods(query, page, pageSize);

    if (cacheEntitiesForDeletion != null) {
      cacheEntitiesForDeletion.removeWhere((element) {
        return foods.indexWhere((e) => e.id == element.id) >= 0;
      });

      for (var entity in cacheEntitiesForDeletion) {
        deleteFood(entity);
      }
    }
  }

  upsertFood(Food food) {
    upsertEntity(food, 'foods');
  }

  deleteFood(Food food) {
    deleteEntity(food, 'foods');
  }
}