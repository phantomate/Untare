// ignore_for_file: unused_catch_clause

import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/food.dart';
import 'package:untare/services/api/api_food.dart';
import 'package:untare/services/cache/cache_food_service.dart';

Future getFoodsFromApiCache(String query) async {
  final CacheFoodService cacheFoodService = CacheFoodService();
  final ApiFood apiFood = ApiFood();

  List<Food>? cacheFoods = cacheFoodService.getFoods(query, 1, 25);

  if (cacheFoods != null) {
    return cacheFoods;
  }

  try {
    Future<List<Food>> foods = apiFood.getFoods(query, 1, 25);
    foods.then((value) => cacheFoodService.upsertFoods(value));
    return foods;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}