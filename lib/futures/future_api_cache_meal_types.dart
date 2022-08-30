// ignore_for_file: unused_catch_clause

import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/meal_type.dart';
import 'package:untare/services/api/api_meal_type.dart';
import 'package:untare/services/cache/cache_meal_plan_service.dart';

Future getMealTypesFromApiCache() async {
  final CacheMealPlanService cacheMealPlanService = CacheMealPlanService();
  final ApiMealType apiMealType = ApiMealType();

  List<MealType>? cacheMealTypes = cacheMealPlanService.getMealTypes();

  try {
    Future<List<MealType>> mealTypes = apiMealType.getMealTypeList();
    mealTypes.then((value) => cacheMealPlanService.upsertMealTypes(value));
    return mealTypes;
  } on ApiConnectionException catch (e) {
    if (cacheMealTypes != null && cacheMealTypes.isNotEmpty) {
      return cacheMealTypes;
    }
  }
}