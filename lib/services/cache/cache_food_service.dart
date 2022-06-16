import 'package:hive/hive.dart';
import 'package:tare/models/food.dart';
import 'package:tare/services/cache/cache_service.dart';

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
}