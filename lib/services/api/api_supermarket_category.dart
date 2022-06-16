import 'dart:convert';

import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:tare/services/api/api_service.dart';

class ApiSupermarketCategory extends ApiService {
  Future<List<SupermarketCategory>> getSupermarketCategories() async {
    var url = '/api/supermarket-category/';

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
          message: 'Supermarket category api error - could not fetch categories',
          statusCode: res.statusCode
      );
    }
  }

  Future<SupermarketCategory> patchSupermarketCategory(SupermarketCategory supermarketCategory) async {
    var url = '/api/supermarket-category/' + supermarketCategory.id.toString() + '/';

    Response res = await httpPatch(url, supermarketCategory.toJson());
    if ([200, 201].contains(res.statusCode)) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

      return SupermarketCategory.fromJson(json);
    } else {
      throw ApiException(
          message: 'Supermarket category api error - could not update category',
          statusCode: res.statusCode
      );
    }
  }

  Future<SupermarketCategory> deleteSupermarketCategory(SupermarketCategory superMarketCategory) async {
    var url = '/api/supermarket-category/' + superMarketCategory.id.toString() + '/';

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return superMarketCategory;
    } else {
      throw ApiException(
          message: 'Supermarket category api error - could not delete category',
          statusCode: res.statusCode
      );
    }
  }
}