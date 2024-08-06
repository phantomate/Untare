// ignore_for_file: unused_catch_clause

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/app_setting.dart';
import 'package:untare/models/user.dart';
import 'package:untare/models/user_setting.dart';
import 'package:untare/services/api/api_user.dart';
import 'package:untare/services/cache/cache_user_service.dart';

class SettingsCubit extends Cubit<AppSetting> {
  var box = Hive.box('unTaReBox');
  final ApiUser apiUser;
  final CacheUserService cacheUserService;

  SettingsCubit({required this.apiUser, required this.cacheUserService}) : super(AppSetting(layout: 'card', defaultPage: 'recipes', materialHexColor: 0xffceb27c));

  void changeDynamicColorTo(bool dynamicColor) {
    AppSetting newState = state.copyWith(dynamicColor: dynamicColor);
    emit(newState);
    box.put('settings', newState);
  }

  void changeLayoutTo(String? layout) {
    if (['list', 'card'].contains(layout)) {
      AppSetting newState = state.copyWith(layout: layout);
      emit(newState);
      box.put('settings', newState);
    }
  }

  void changeThemeTo(String? theme) {
    if (['light', 'dark', 'system'].contains(theme)) {
      AppSetting newState = state.copyWith(theme: theme);
      emit(newState);
      box.put('settings', newState);
    }
  }

  void changeDefaultPageTo(String? defaultPage) {
    if (['recipes', 'plan', 'shopping'].contains(defaultPage)) {
      AppSetting newState = state.copyWith(defaultPage: defaultPage);
      emit(newState);
      box.put('settings', newState);
    }
  }

  void changeColorTo(int materialHexColor) {
    AppSetting newState = state.copyWith(materialHexColor: materialHexColor);
    emit(newState);
    box.put('settings', newState);
  }

  void initServerSetting() async {
    User? user = box.get('user');
    if (user != null) {
      UserSetting? cacheUserSetting = cacheUserService.getUserSetting(user);

      if (cacheUserSetting != null) {
        emit(state.copyWith(userServerSetting: cacheUserSetting));
      }

      try {
        UserSetting userSetting = await apiUser.getUserSettings(user);
        AppSetting newState = state.copyWith(userServerSetting: userSetting);
        emit(newState);
        box.put('settings', newState);

        cacheUserService.upsertUserSetting(userSetting);
      } on ApiConnectionException catch (e) {
        // Do nothing
      }
    }
  }

  void setServerSetting(UserSetting userSetting) {
    AppSetting newState = state.copyWith(userServerSetting: userSetting);
    emit(newState);
    box.put('settings', newState);
  }

  void updateServerSetting(UserSetting userSetting) async {
    User? user = box.get('user');
    if (user != null) {
      try {
        UserSetting newUserSetting = await apiUser.patchUserSettings(user, userSetting);

        AppSetting newState = state.copyWith(userServerSetting: newUserSetting);
        emit(newState);
        box.put('settings', newState);

        cacheUserService.upsertUserSetting(newUserSetting);
      } on ApiConnectionException catch (e) {
        AppSetting newState = state.copyWith(userServerSetting: userSetting);
        emit(newState);
        box.put('settings', newState);

        cacheUserService.upsertUserSetting(userSetting);
      }
    }
  }
}