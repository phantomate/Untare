import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:tare/models/meal_type.dart';
import 'package:tare/services/api/api_meal_type.dart';
import 'package:tare/services/cache/cache_meal_plan_service.dart';

Future getMealTypesFromApiCache() async {
  final CacheMealPlanService _cacheMealPlanService = CacheMealPlanService();
  final ApiMealType _apiMealType = ApiMealType();

  List<MealType>? cacheMealTypes = _cacheMealPlanService.getMealTypes();

  if (cacheMealTypes != null) {
    return cacheMealTypes;
  }

  try {
    Future<List<MealType>> mealTypes = _apiMealType.getMealTypeList();
    mealTypes.then((value) => _cacheMealPlanService.upsertMealTypes(value));
    return mealTypes;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}