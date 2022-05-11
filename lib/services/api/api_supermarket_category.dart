import 'dart:convert';

import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:tare/services/api/api_service.dart';

class ApiSupermarketCategory extends ApiService {
  Future<List<SupermarketCategory>> getSupermarketCategories() async {
    var url = '/api/supermarket-category';

    Response res = await httpGet(url);
    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonSupermarketCategories = jsonDecode(utf8.decode(res.bodyBytes));
      List<SupermarketCategory> supermarketCategories = [];

      jsonSupermarketCategories.forEach((element) {
        supermarketCategories.add(SupermarketCategory.fromJson(element));
      });

      return supermarketCategories;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
          message: 'Supermarket category api error',
          statusCode: res.statusCode
      );
    }
  }
}