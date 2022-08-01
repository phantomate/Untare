import 'dart:convert';
import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/unit.dart';
import 'package:tare/services/api/api_service.dart';

class ApiUnit extends ApiService {
  Future<List<Unit>> getUnits(String query, int page, int pageSize) async {
    var url = '/api/unit/';
    url += '?query=' + query;
    url += '&page=' + page.toString();
    url += '&page_size=' + pageSize.toString();

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
      throw e;
    }
  }
}