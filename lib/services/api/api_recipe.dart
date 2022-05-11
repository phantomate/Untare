import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/exceptions/mapping_exception.dart';
import 'package:tare/models/recipe.dart';
import 'dart:convert';
import 'package:tare/services/api/api_service.dart';
import 'package:http_parser/http_parser.dart';

class ApiRecipe extends ApiService {
  Future<List<Recipe>> getRecipeList(String query, bool random, int page, int pageSize, String? sortOrder) async {
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

    if ([200, 201].contains(res.statusCode)) {
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

    if ([200, 201].contains(res.statusCode)) {
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

    if ([200, 201].contains(res.statusCode)) {
      return Recipe.fromJson(json);
    } else {
      throw ApiException(
          message: 'Recipe api error: ' + (json['detail'] ?? json['error']),
          statusCode: res.statusCode
      );
    }
  }

  Future updateImage(Recipe recipe, image) async {
    if (recipe.id == null) {
      throw MappingException(message: 'Id missing for recipe image update ' + recipe.name);
    }
    var url = '/api/recipe/' + recipe.id.toString() + '/image/';

    var request = MultipartRequest('PUT', Uri.parse(url));
    request.files.add(MultipartFile.fromBytes('file', file.readAsBytesSync(), contentType: MediaType('image','jpeg')));

    request.send().then((response) {
      print('response: ' + response.toString());
      if ([200, 201].contains(response)) print("Uploaded!");
    });
  }

  Future addIngredientsToShoppingList(int recipeId, List<int> ingredientIds, int servings) async {
    var url = '/api/recipe/' + recipeId.toString() + '/shopping';

    Map<String, dynamic> requestJson = {
      'id': recipeId,
      'ingredients': ingredientIds,
      'servings': servings
    };

    Response res = await httpPut(url, requestJson);

    if (![200, 201, 204].contains(res.statusCode)) {
      throw ApiException(
          message: 'Recipe api error on adding ingredients to shopping list',
          statusCode: res.statusCode
      );
    }
  }

  Future<Recipe> createRecipe(Recipe recipe) async {
    var url = '/api/recipe/';

    Response res = await httpPost(url, recipe.toJson());
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return Recipe.fromJson(json);
    } else {
      throw ApiException(
          message: 'Recipe api error',
          statusCode: res.statusCode
      );
    }
  }

  Future<Recipe> deleteRecipe(Recipe recipe) async {
    if (recipe.id == null) {
      throw MappingException(message: 'Id missing for deleting recipe ' + recipe.name);
    }
    var url = '/api/recipe/' + recipe.id.toString();

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return recipe;
    } else {
      throw ApiException(
          message: 'Recipe api error',
          statusCode: res.statusCode
      );
    }
  }
}