import 'package:tare/models/user_setting.dart';
import 'package:hive/hive.dart';

part 'app_setting.g.dart';

@HiveType(typeId: 1)
class AppSetting {

  @HiveField(0)
  final String layout;
  @HiveField(1)
  final String theme;
  @HiveField(2)
  final String defaultPage;
  @HiveField(3)
  final UserSetting? userServerSetting;

  AppSetting({
    required this.layout,
    required this.theme,
    required this.defaultPage,
    this.userServerSetting
  });

  AppSetting copyWith({
    String? layout,
    String? theme,
    String? defaultPage,
    UserSetting? userServerSetting
  }) {
    return AppSetting(
      layout: layout ?? this.layout,
      theme: theme ?? this.theme,
      defaultPage: defaultPage ?? this.defaultPage,
      userServerSetting: userServerSetting ?? this.userServerSetting
    );
  }
}