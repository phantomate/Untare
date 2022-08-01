import 'dart:convert';

import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/keyword.dart';
import 'package:tare/services/api/api_service.dart';

class ApiKeyword extends ApiService {
  Future<List<Keyword>> getKeywords(String query, int page, int pageSize) async {
    var url = '/api/keyword/';
    url += '?query=' + query;
    url += '&page=' + page.toString();
    url += '&page_size=' + pageSize.toString();

    Response res = await httpGet(url);
    print('haloooo');
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonKeywords = json['results'];

      List<Keyword> keywords = jsonKeywords.map((item) => Keyword.fromJson(item)).toList();

      print('key:' + keywords.toString());

      return keywords;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
          message: 'Keyword api error: ' + (json['detail'] ?? json['error']),
          statusCode: res.statusCode
      );
    }
  }
}