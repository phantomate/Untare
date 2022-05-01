import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/exceptions/mapping_exception.dart';
import 'package:tare/models/recipe.dart';
import 'dart:convert';
import 'package:tare/services/api/api_service.dart';

class ApiRecipe extends ApiService {
  Future<List<Recipe>> getRecipes(String query, bool random, int page, int pageSize, String? sortOrder) async {
    var url = '/api/recipe';
    url += '?query=' + query;
    url += '&random=' + random.toString();
    url += '&page=' + page.toString();
    url += '&page_size=' + pageSize.toString();

    if (sortOrder != null) {
      url += '&sort_order=' + sortOrder;
    }

    Response res = await httpGet(url);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode == 200) {
      List<dynamic> jsonRecipes = json['results'];

      List<Recipe> recipes = jsonRecipes.map((dynamic item) => Recipe.fromJson(item)).toList();

      return recipes;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
        message: 'Recipe api error: ' + (json['detail'] ?? json['error']),
        statusCode: res.statusCode
      );
    }
  }

  Future<Recipe?> getRecipe(int id) async {
    var url = '/api/recipe/' + id.toString();

    Response res = await httpGet(url);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode == 200) {
      return Recipe.fromJson(json);
    } else if (res.statusCode == 404) {
      return null;
    } else {
      throw ApiException(
          message: 'Recipe api error: ' + (json['detail'] ?? json['error']),
          statusCode: res.statusCode
      );
    }
  }

  Future<Recipe> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) {
      throw MappingException(message: 'Id missing for updating recipe ' + recipe.name);
    }
    var url = '/api/recipe/' + recipe.id.toString();

    Response res = await httpPut(url, recipe.toJson());

    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode == 200) {
      return Recipe.fromJson(json);
    } else {
      throw ApiException(
          message: 'Recipe api error: ' + (json['detail'] ?? json['error']),
          statusCode: res.statusCode
      );
    }
  }

  Future<Recipe> updateImage(Recipe recipe, image) async {
    if (recipe.id == null) {
      throw MappingException(message: 'Id missing for recipe image update ' + recipe.name);
    }
    var url = '/api/recipe/' + recipe.id.toString() + '/image/';

    Response res = await httpPut(url, image);

    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode == 200) {
      return recipe.copyWith(image: json['image']);
    } else {
      throw ApiException(
          message: 'Recipe api error: ' + (json['detail'] ?? json['error']),
          statusCode: res.statusCode
      );
    }
  }
}