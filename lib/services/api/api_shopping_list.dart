import 'dart:convert';

import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/exceptions/mapping_exception.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:tare/services/api/api_service.dart';

class ApiShoppingList extends ApiService {
  Future<List<ShoppingListEntry>> getShoppingListEntries(String checked, String idFilter) async {
    var url = '/api/shopping-list-entry/';
    url += '?checked=' + checked;
    url += idFilter;

    Response res = await httpGet(url);
    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonShoppingListEntries = jsonDecode(utf8.decode(res.bodyBytes));
      List<ShoppingListEntry> shoppingListEntries = [];

      jsonShoppingListEntries.forEach((element) {
        shoppingListEntries.add(ShoppingListEntry.fromJson(element));
      });

      return shoppingListEntries;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
          message: 'Shopping list api error - could not fetch shopping list entries',
          statusCode: res.statusCode
      );
    }
  }

  Future<ShoppingListEntry> createShoppingListEntry(ShoppingListEntry entry) async {
    var url = '/api/shopping-list-entry/';

    Response res = await httpPost(url, entry.toJson());
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return ShoppingListEntry.fromJson(json);
    } else {
      throw ApiException(
          message: 'Shopping list api error - could not create shopping list entry',
          statusCode: res.statusCode
      );
    }
  }

  Future<ShoppingListEntry> updateShoppingListEntry(ShoppingListEntry entry) async {
    if (entry.id == null) {
      throw MappingException(message: 'Id missing for updating shopping list entry');
    }
    var url = '/api/shopping-list-entry/' + entry.id.toString() + '/';

    Response res = await httpPut(url, entry.toJson());

    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return ShoppingListEntry.fromJson(json);
    } else {
      throw ApiException(
          message: 'Shopping list api error - could not update shopping list entry',
          statusCode: res.statusCode
      );
    }
  }

  Future<ShoppingListEntry> patchShoppingListEntryCheckedStatus(ShoppingListEntry entry) async {
    if (entry.id == null) {
      throw MappingException(message: 'Id missing for patching shopping list entry');
    }
    var url = '/api/shopping-list-entry/' + entry.id.toString() + '/';

    Map<String, dynamic> requestJson = {
      'id': entry.id,
      'checked': entry.checked
    };

    Response res = await httpPatch(url, requestJson);

    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return ShoppingListEntry.fromJson(json);
    } else {
      throw ApiException(
          message: 'Shopping list api error - could not update shopping list entry',
          statusCode: res.statusCode
      );
    }
  }

  Future<ShoppingListEntry> deleteShoppingListEntry(ShoppingListEntry entry) async {
    if (entry.id == null) {
      throw MappingException(message: 'Id missing for deleting shopping list entry');
    }
    var url = '/api/shopping-list-entry/' + entry.id.toString();

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return entry;
    } else {
      throw ApiException(
          message: 'Shopping list api error - could not delete shopping list entry',
          statusCode: res.statusCode
      );
    }
  }
}