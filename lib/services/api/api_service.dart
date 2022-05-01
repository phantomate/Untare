import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart';

abstract class ApiService {
  var box = Hive.box('appBox');

  Future httpGet(String url) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await get(Uri.parse(baseUrl! + url), headers: headers);

    if (response.statusCode == 403) {
      box.clear();
    }

    return response;
  }

  Future httpPost(String url, data) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await post(Uri.parse(baseUrl! + url), body: jsonEncode(data), headers: headers);

    if (response.statusCode == 403) {
      box.clear();
    }

    return response;
  }

  Future httpPut(String url, data) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await put(Uri.parse(baseUrl! + url), body: jsonEncode(data), headers: headers);

    if (response.statusCode == 403) {
      box.clear();
    }

    return response;
  }

  Future getHeaders() async {
    String? token =box.get('token');

    Map<String, String> headers = {
      'content-type': 'application/json',
      'authorization': 'token ' + (token ?? ''),
      'charset': 'UTF-8'
    };

    return headers;
  }
}