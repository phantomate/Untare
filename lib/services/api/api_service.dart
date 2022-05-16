import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:http/http.dart';

abstract class ApiService {
  var box = Hive.box('hydrated_box');

  Future httpGet(String url) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await get(Uri.parse(baseUrl! + url), headers: headers);

    if (response.statusCode == 401) {
      box.clear();
    }

    return response;
  }

  Future httpPost(String url, data) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await post(Uri.parse(baseUrl! + url), body: jsonEncode(data), headers: headers);

    if (response.statusCode == 401) {
      box.clear();
    }

    return response;
  }

  Future httpPut(String url, data) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await put(Uri.parse(baseUrl! + url), body: jsonEncode(data), headers: headers);

    if (response.statusCode == 401) {
      box.clear();
    }

    return response;
  }

  Future httpPatch(String url, data) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await patch(Uri.parse(baseUrl! + url), body: jsonEncode(data), headers: headers);

    if (response.statusCode == 401) {
      box.clear();
    }

    return response;
  }

  Future httpDelete(String url) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();
    Response response = await delete(Uri.parse(baseUrl! + url), headers: headers);

    if (response.statusCode == 401) {
      box.clear();
    }

    return response;
  }

  Future httpPutImage(String url, image) async {
    String? baseUrl = box.get('url');
    Map<String, String> headers = await getHeaders();

    File file = File(image.path);

    var request = MultipartRequest('PUT', Uri.parse(baseUrl! + url));
    request.files.add(new MultipartFile('image', file.readAsBytes().asStream(), file.lengthSync(), filename: image.path.split('/').last));
    request.headers.addAll(headers);

    return request.send();
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