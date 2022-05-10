import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeModeCubit extends Cubit<String> {
  var box = Hive.box('appBox');

  ThemeModeCubit() : super('light');

  void initThemeMode(String? theme) async {
    if (theme != null) {
      emit(theme);
    }
  }

  void changeToLightTheme() {
    box.put('theme', 'light');
    emit('light');
  }

  void changeToDarkTheme() {
    box.put('theme', 'dark');
    emit('dark');
  }
}