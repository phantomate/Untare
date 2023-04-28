// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:http/http.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/exceptions/mapping_exception.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/models/share.dart';
import 'dart:convert';
import 'package:untare/services/api/api_service.dart';

class ApiRecipe extends ApiService {
  Future<List<Recipe>> getRecipeList(String query, bool random, int page, int pageSize, String? sortOrder) async {
    var url = '/api/recipe/';
    url += '?query=$query';
    url += '&random=$random';
    url += '&page=$page';
    url += '&page_size=$pageSize';

    if (sortOrder != null) {
      url += '&sort_order=$sortOrder';
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
    var url = '/api/recipe/$id/';

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

  Future<ShareModel?> getRecipeShareLink(int id) async {
    var url = '/api/share-link/$id';

    Response res = await httpGet(url);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return ShareModel.fromJson(json);
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
      throw MappingException(message: 'Id missing for updating recipe ${recipe.name}');
    }
    var url = '/api/recipe/${recipe.id}/';
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

  Future<Recipe> updateImage(Recipe recipe, image) async {
    if (recipe.id == null) {
      throw MappingException(message: 'Id missing for recipe image update ${recipe.name}');
    }
    var url = '/api/recipe/${recipe.id}/image/';

    Response res = await httpPutImage(url, image);

    if ([200, 201].contains(res.statusCode)) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
      return recipe.copyWith(image: box.get('url') + json['image']);
    } else {
      throw ApiException(
          message: 'Recipe api error on uploading image',
          statusCode: res.statusCode
      );
    }
  }

  Future addIngredientsToShoppingList(int recipeId, List<int> ingredientIds, int servings) async {
    var url = '/api/recipe/$recipeId/shopping/';

    Map<String, dynamic> requestData = {
      'id': recipeId,
      'ingredients': ingredientIds,
      'servings': servings
    };

    Response res = await httpPut(url, requestData);

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
      throw MappingException(message: 'Id missing for deleting recipe ${recipe.name}');
    }
    var url = '/api/recipe/${recipe.id}/';

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return recipe;
    } else {
      throw ApiException(
          message: 'Recipe api error - could not delete recipe',
          statusCode: res.statusCode
      );
    }
  }

  Future<Recipe> importRecipe(String recipeUrl) async {
    var url = '/api/recipe-from-source/';

    Map<String, dynamic> requestData = {
      'data': '',
      'url': recipeUrl
    };

    Response res = await httpPost(url, requestData);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      if (json['link'] != null) {
        final linkParts = json['link'].split('/');
        Recipe? recipe = await getRecipe(int.parse(linkParts[linkParts.length-1]));
        return recipe!;
      } else {
        return Recipe.fromJson(json['recipe_json']);
      }
    } else {
      throw ApiException(
          message: 'Recipe api error - could not import recipe',
          statusCode: res.statusCode
      );
    }
  }
}