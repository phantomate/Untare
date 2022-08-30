// ignore_for_file: unused_catch_clause

import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/user.dart';
import 'package:untare/services/api/api_user.dart';
import 'package:untare/services/cache/cache_user_service.dart';

Future getUsersFromApiCache() async {
  final CacheUserService cacheUsersService = CacheUserService();
  final ApiUser apiUser = ApiUser();

  List<User>? cacheUsers = cacheUsersService.getUsers();

  try {
    Future<List<User>> users = apiUser.getUsers();
    users.then((value) => cacheUsersService.upsertUsers(value));
    return users;
  } on ApiConnectionException catch (e) {
    if (cacheUsers != null && cacheUsers.isNotEmpty) {
      return cacheUsers;
    }
  }
}