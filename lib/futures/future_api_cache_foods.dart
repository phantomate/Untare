import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:tare/models/food.dart';
import 'package:tare/services/api/api_food.dart';
import 'package:tare/services/cache/cache_food_service.dart';

Future getFoodsFromApiCache(String query) async {
  final CacheFoodService _cacheFoodService = CacheFoodService();
  final ApiFood _apiFood = ApiFood();

  List<Food>? cacheFoods = _cacheFoodService.getFoods(query, 1, 20);

  if (cacheFoods != null) {
    return cacheFoods;
  }

  try {
    Future<List<Food>> foods = _apiFood.getFoods(query, 1, 25);
    foods.then((value) => _cacheFoodService.upsertFoods(value));
    return foods;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}