import 'dart:convert';

import 'package:http/http.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/user.dart';
import 'package:tare/models/user_setting.dart';
import 'package:tare/services/api/api_service.dart';

class ApiUser extends ApiService {
  Future<List<User>> getUsers() async {
    var url = '/api/user-name/';

    Response res = await httpGet(url);

    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
      List<User> userList = [];

      json.forEach((element) {
        userList.add(User.fromJson(element));
      });

      return userList;
    } else {
      throw ApiException(
          message: 'User api error - could not fetch user data',
          statusCode: res.statusCode
      );
    }
  }

  Future<UserSetting> getUserSettings(User user) async {
    var url = '/api/user-preference/' + user.id.toString() + '/';

    Response res = await httpGet(url);

    if ([200, 201].contains(res.statusCode)) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

      return UserSetting.fromJson(json);
    } else {
      throw ApiException(
          message: 'User api error - could not fetch user settings',
          statusCode: res.statusCode
      );
    }
  }

  Future<UserSetting> patchUserSettings(User user, UserSetting userSetting) async {
    var url = '/api/user-preference/' + user.id.toString() + '/';

    Response res = await httpPatch(url, userSetting.toJson());

    if ([200, 201].contains(res.statusCode)) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
      return UserSetting.fromJson(json);
    } else {
      throw ApiException(
          message: 'User api error - could not fetch user settings',
          statusCode: res.statusCode
      );
    }
  }
}