import 'dart:convert';

import 'package:http/http.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/exceptions/mapping_exception.dart';
import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/services/api/api_service.dart';

class ApiMealPlan extends ApiService {
  Future<List<MealPlanEntry>> getMealPlanList(String from, String to) async {
    var url = '/api/meal-plan/';
    url += '?from_date=$from';
    url += '&to_date=$to';

    Response res = await httpGet(url);
    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonMealPlanList = jsonDecode(utf8.decode(res.bodyBytes));
      List<MealPlanEntry> mealPlanList = [];

      for (var element in jsonMealPlanList) {
        mealPlanList.add(MealPlanEntry.fromJson(element));
      }

      return mealPlanList;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
          message: 'Meal plan api error - could not fetch meal plan list',
          statusCode: res.statusCode
      );
    }
  }

  Future<MealPlanEntry> createMealPlan(MealPlanEntry mealPlan) async {
    var url = '/api/meal-plan/';

    Response res = await httpPost(url, mealPlan.toJson());
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return MealPlanEntry.fromJson(json);
    } else {
      throw ApiException(
          message: 'Meal plan api error - could not create meal plan',
          statusCode: res.statusCode
      );
    }
  }

  Future<MealPlanEntry> updateMealPlan(MealPlanEntry mealPlan) async {
    if (mealPlan.id == null) {
      throw MappingException(message: 'Id missing for updating meal plan');
    }
    var url = '/api/meal-plan/${mealPlan.id}/';

    Response res = await httpPut(url, mealPlan.toJson());

    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return MealPlanEntry.fromJson(json);
    } else {
      throw ApiException(
          message: 'Meal plan api error - could not update meal plan',
          statusCode: res.statusCode
      );
    }
  }

  Future<MealPlanEntry> deleteMealPlan(MealPlanEntry mealPlan) async {
    if (mealPlan.id == null) {
      throw MappingException(message: 'Id missing for deleting meal plan');
    }
    var url = '/api/meal-plan/${mealPlan.id}/';

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return mealPlan;
    } else {
      throw ApiException(
          message: 'Meal plan api error - could not delete meal plan',
          statusCode: res.statusCode
      );
    }
  }
}