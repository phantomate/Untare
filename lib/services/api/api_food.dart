// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:http/http.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/exceptions/mapping_exception.dart';
import 'package:untare/models/food.dart';

import 'api_service.dart';

class ApiFood extends ApiService {
  Future<List<Food>> getFoods(String query, int page, int pageSize) async {
    var url = '/api/food/';
    url += '?query=$query';
    url += '&page=$page';
    url += '&page_size=$pageSize';
    url += '&extended=1';

    Response res = await httpGet(url);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonUnits = json['results'];

      List<Food> foods = jsonUnits.map((item) => Food.fromJson(item)).toList();

      return foods;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
          message: 'Food api error: ' + (json['detail'] ?? json['error']),
          statusCode: res.statusCode
      );
    }
  }

  Future<Food> patchFoodOnHand(Food food) async {
    if (food.id == null) {
      throw MappingException(message: 'Id missing for patching food');
    }
    var url = '/api/food/${food.id}/';

    Map<String, dynamic> requestJson = {
      'food_onhand': food.onHand
    };

    Response res = await httpPatch(url, requestJson);

    if ([200, 201].contains(res.statusCode)) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
      return Food.fromJson(json);
    } else {
      throw ApiException(
          message: 'Food api error - could not update food on hand',
          statusCode: res.statusCode
      );
    }
  }

  Future<Food> createFood(Food food) async {
    var url = '/api/food/';

    Response res = await httpPost(url, food.toJson());
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return Food.fromJson(json);
    } else {
      throw ApiException(
          message: 'Food api error - could not create food',
          statusCode: res.statusCode
      );
    }
  }

  Future<Food> updateFood(Food food) async {
    if (food.id == null) {
      throw MappingException(message: 'Id missing for updating food');
    }
    var url = '/api/food/${food.id}/';

    Response res = await httpPut(url, food.toJson());

    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return Food.fromJson(json);
    } else {
      throw ApiException(
          message: 'Food api error - could not update food',
          statusCode: res.statusCode
      );
    }
  }

  Future<Food> deleteFood(Food food) async {
    if (food.id == null) {
      throw MappingException(message: 'Id missing for deleting food');
    }
    var url = '/api/food/${food.id}/';

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return food;
    } else {
      throw ApiException(
          message: 'Food api error - could not delete food',
          statusCode: res.statusCode
      );
    }
  }
}