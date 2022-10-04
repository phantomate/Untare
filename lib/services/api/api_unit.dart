// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:http/http.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/exceptions/mapping_exception.dart';
import 'package:untare/models/unit.dart';
import 'package:untare/services/api/api_service.dart';

class ApiUnit extends ApiService {
  Future<List<Unit>> getUnits(String query, int page, int pageSize) async {
    var url = '/api/unit/';
    url += '?query=$query';
    url += '&page=$page';
    url += '&page_size=$pageSize';

    try {
      Response res = await httpGet(url);
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

      if ([200, 201].contains(res.statusCode)) {
        List<dynamic> jsonUnits = json['results'];

        List<Unit> units = jsonUnits.map((item) => Unit.fromJson(item)).toList();

        return units;
      } else if (res.statusCode == 404) {
        return [];
      } else {
        throw ApiException(
            message: 'Unit api error: ' + (json['detail'] ?? json['error']),
            statusCode: res.statusCode
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Unit> createUnit(Unit unit) async {
    var url = '/api/unit/';

    Response res = await httpPost(url, unit.toJson());
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return Unit.fromJson(json);
    } else {
      throw ApiException(
          message: 'Unit api error - could not create unit',
          statusCode: res.statusCode
      );
    }
  }

  Future<Unit> updateUnit(Unit unit) async {
    if (unit.id == null) {
      throw MappingException(message: 'Id missing for updating unit');
    }
    var url = '/api/unit/${unit.id}/';

    Response res = await httpPut(url, unit.toJson());

    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      return Unit.fromJson(json);
    } else {
      throw ApiException(
          message: 'Unit api error - could not update unit',
          statusCode: res.statusCode
      );
    }
  }

  Future<Unit> deleteUnit(Unit unit) async {
    if (unit.id == null) {
      throw MappingException(message: 'Id missing for deleting unit');
    }
    var url = '/api/unit/${unit.id}/';

    Response res = await httpDelete(url);

    if ([200, 201, 204].contains(res.statusCode)) {
      return unit;
    } else {
      throw ApiException(
          message: 'Unit api error - could not delete unit',
          statusCode: res.statusCode
      );
    }
  }
}