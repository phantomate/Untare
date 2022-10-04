import 'dart:convert';

import 'package:http/http.dart';
import 'package:untare/models/meal_type.dart';
import 'package:untare/services/api/api_service.dart';

import '../../exceptions/api_exception.dart';

class ApiMealType extends ApiService {
  Future<List<MealType>> getMealTypeList() async {
    var url = '/api/meal-type/';

    Response res = await httpGet(url);
    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonMealTypeList = jsonDecode(utf8.decode(res.bodyBytes));
      List<MealType> mealTypeList = [];

      for (var element in jsonMealTypeList) {
        mealTypeList.add(MealType.fromJson(element));
      }

      return mealTypeList;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
          message: 'Meal type api error - could not fetch meal type list',
          statusCode: res.statusCode
      );
    }
  }

  Future<MealType> patchMealType(MealType mealType) async {
    var url = '/api/meal-type/${mealType.id}/';

    Response res = await httpPatch(url, mealType.toJson());
    if ([200, 201].contains(res.statusCode)) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

      return MealType.fromJson(json);
    } else {
      throw ApiException(
          message: 'Meal type api error - could not update meal type',
          statusCode: res.statusCode
      );
    }
  }

  Future<MealType> deleteMealType(MealType mealType) async {
    var url = '/api/meal-type/${mealType.id}/';

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return mealType;
    } else {
      throw ApiException(
          message: 'Meal type api error - could not delete meal type',
          statusCode: res.statusCode
      );
    }
  }
}