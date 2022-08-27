import 'package:untare/models/user.dart';
import 'package:untare/models/user_setting.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheUserService extends CacheService {

  List<User>? getUsers() {
    List<dynamic>? users = box.get('users');

    if (users != null) {
      return users.cast<User>();
    }

    return null;
  }

  upsertUsers(List<User> users) {
    upsertEntityList(users, 'users');
  }

  User? getUser(int id) {
    List<dynamic>? cache = box.get('users');
    List<User>? cacheUsers = (cache != null) ? cache.cast<User>() : null;

    if (cacheUsers != null && cacheUsers.isNotEmpty) {
      int cacheUserIndex = cacheUsers.indexWhere((cacheUser) => cacheUser.id == id);

      if (cacheUserIndex >= 0) {
        return cacheUsers[cacheUserIndex];
      }
    }
    return null;
  }

  upsertUser(User user) {
    upsertEntity(user, 'users');
  }

  UserSetting? getUserSetting(User user) {
    List<dynamic>? cache = box.get('userSettings');
    List<UserSetting>? cacheUserSettings = (cache != null) ? cache.cast<UserSetting>() : null;

    if (cacheUserSettings != null && cacheUserSettings.isNotEmpty) {
      int cacheUserSettingIndex = cacheUserSettings.indexWhere((cacheUserSetting) => cacheUserSetting.user == user.id);

      if (cacheUserSettingIndex >= 0) {
        return cacheUserSettings[cacheUserSettingIndex];
      }
    }
    return null;
  }

  upsertUserSetting(UserSetting userSetting) {
    List<dynamic>? cacheUserSettings = box.get('userSettings');

    if (cacheUserSettings != null && cacheUserSettings.isNotEmpty) {
      int cacheUserSettingIndex = cacheUserSettings.indexWhere((cacheUserSetting) => cacheUserSetting.user == userSetting.user);

      if (cacheUserSettingIndex >= 0) {
        cacheUserSettings[cacheUserSettingIndex] = userSetting;
      } else {
        cacheUserSettings.add(userSetting);
      }
    } else {
      cacheUserSettings = [];
      cacheUserSettings.add(userSetting);
    }

    box.put('userSettings', cacheUserSettings);
  }
}