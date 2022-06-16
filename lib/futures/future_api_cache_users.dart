import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:tare/models/user.dart';
import 'package:tare/services/api/api_user.dart';
import 'package:tare/services/cache/cache_user_service.dart';

Future getUsersFromApiCache() async {
  final CacheUserService _cacheUsersService = CacheUserService();
  final ApiUser _apiUser = ApiUser();

  List<User>? cacheUsers = _cacheUsersService.getUsers();

  if (cacheUsers != null) {
    return cacheUsers;
  }

  try {
    Future<List<User>> users = _apiUser.getUsers();
    users.then((value) => _cacheUsersService.upsertUsers(value));
    return users;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}