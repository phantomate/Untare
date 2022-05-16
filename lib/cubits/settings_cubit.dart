import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tare/models/app_setting.dart';
import 'package:tare/models/user.dart';
import 'package:tare/models/user_setting.dart';
import 'package:tare/services/api/api_user.dart';

class SettingsCubit extends Cubit<AppSetting> {
  var box = Hive.box('hydrated_box');
  final ApiUser apiUser;


  SettingsCubit({required this.apiUser}) : super(AppSetting(layout: 'card', theme: 'light', defaultPage: 'recipes'));

  void changeLayoutTo(String? layout) {
    if (['list', 'card'].contains(layout)) {
      emit(state.copyWith(layout: layout));
      box.put('settings', state);
    }
  }

  void changeThemeTo(String? theme) {
    if (['light', 'dark'].contains(theme)) {
      emit(state.copyWith(theme: theme));
      box.put('settings', state);
    }
  }

  void changeDefaultPageTo(String? defaultPage) {
    if (['recipes', 'plan', 'shopping'].contains(defaultPage)) {
      emit(state.copyWith(defaultPage: defaultPage));
      box.put('settings', state);
    }
  }

  void initServerSetting() async {
    User? user = box.get('user');
    if (user != null) {
      UserSetting userSetting = await apiUser.getUserSettings(user);

      emit(state.copyWith(userServerSetting: userSetting));
      box.put('settings', state);
    }
  }
}