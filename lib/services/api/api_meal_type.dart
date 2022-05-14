import 'dart:convert';

import 'package:http/http.dart';
import 'package:tare/models/meal_type.dart';
import 'package:tare/services/api/api_service.dart';

import '../../exceptions/api_exception.dart';

class ApiMealType extends ApiService {
  Future<List<MealType>> getMealTypeList() async {
    var url = '/api/meal-type/';

    Response res = await httpGet(url);
    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonMealTypeList = jsonDecode(utf8.decode(res.bodyBytes));
      List<MealType> mealTypeList = [];

      jsonMealTypeList.forEach((element) {
        mealTypeList.add(MealType.fromJson(element));
      });

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
}