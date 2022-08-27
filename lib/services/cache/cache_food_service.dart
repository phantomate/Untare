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

  upsertFoods(List<Food> foods) {
    upsertEntityList(foods, 'foods');
  }

  upsertFood(Food food) {
    upsertEntity(food, 'foods');
  }

  deleteFood(Food food) {
    deleteEntity(food, 'foods');
  }
}