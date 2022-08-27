import 'dart:convert';

import 'package:http/http.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/models/space.dart';
import 'package:untare/services/api/api_service.dart';

class ApiSpace extends ApiService {
  Future<List<Space>> getSpaces() async {
    var url = '/api/space/';

    Response res = await httpGet(url);

    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> jsonSpaces = jsonDecode(utf8.decode(res.bodyBytes));
      List<Space> spaces = jsonSpaces.map((item) => Space.fromJson(item)).toList();

      return spaces;
    } else if (res.statusCode == 404) {
      return [];
    } else {
      throw ApiException(
          message: 'Space api error - could not fetch space list',
          statusCode: res.statusCode
      );
    }
  }

  Future<Space> switchActiveSpace(Space space) async {
    var url = '/api/switch-active-space/${space.id}/';

    Response res = await httpGet(url);
    if ([200, 201].contains(res.statusCode)) {
      return space;
    } else {
      throw ApiException(
          message: 'Space api error - could not switch active space',
          statusCode: res.statusCode
      );
    }
  }
}