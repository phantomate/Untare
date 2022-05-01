import 'dart:convert';

import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/food.dart';

import 'api_service.dart';

class ApiFood extends ApiService {
  Future<List<Food>> getFoods(String query, int page, int pageSize) async {
    var url = '/api/food';
    url += '?query=' + query;
    url += '&page=' + page.toString();
    url += '&page_size=' + pageSize.toString();

    Response res = await httpGet(url);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode == 200) {
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
}