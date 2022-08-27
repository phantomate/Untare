import 'dart:convert';

import 'package:http/http.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/models/user.dart';
import 'package:untare/models/userToken.dart';
import 'package:untare/models/user_setting.dart';
import 'package:untare/services/api/api_service.dart';

class ApiUser extends ApiService {
  Future<List<User>> getUsers() async {
    var url = '/api/user/';

    Response res = await httpGet(url);

    if ([200, 201].contains(res.statusCode)) {
      List<dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
      List<User> userList = [];

      for (var element in json) {
        userList.add(User.fromJson(element));
      }

      return userList;
    } else {
      throw ApiException(
          message: 'User api error - could not fetch user data',
          statusCode: res.statusCode
      );
    }
  }

  Future<UserToken> createAuthToken(String username, String password) async {
    var url = '/api-token-auth/';

    Map<String, dynamic> requestData = {
      'username': username,
      'password': password
    };

    Response res = await httpPost(url, requestData, withoutToken: true);

    if ([200, 201].contains(res.statusCode)) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
      return UserToken.fromJson(json);
    } else {
      throw ApiException(
          message: 'User api error - wrong credentials',
          statusCode: res.statusCode
      );
    }
  }

  Future<UserSetting> getUserSettings(User user) async {
    var url = '/api/user-preference/${user.id}/';

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
    var url = '/api/user-preference/${user.id}/';

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