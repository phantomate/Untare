import 'package:untare/models/user_setting.dart';
import 'package:hive/hive.dart';

part 'app_setting.g.dart';

@HiveType(typeId: 1)
class AppSetting {

  @HiveField(0)
  final String layout;
  @HiveField(1)
  final String? theme;
  @HiveField(2)
  final String defaultPage;
  @HiveField(3)
  final int materialHexColor;
  @HiveField(4)
  final UserSetting? userServerSetting;
  @HiveField(5)
  final bool dynamicColor;

  AppSetting({
    required this.layout,
    this.theme,
    required this.defaultPage,
    required this.materialHexColor,
    this.userServerSetting,
    this.dynamicColor = true
  });

  AppSetting copyWith({
    String? layout,
    String? theme,
    String? defaultPage,
    int? materialHexColor,
    UserSetting? userServerSetting,
    bool? dynamicColor
  }) {
    return AppSetting(
      layout: layout ?? this.layout,
      theme: theme ?? this.theme,
      defaultPage: defaultPage ?? this.defaultPage,
      materialHexColor: materialHexColor ?? this.materialHexColor,
      userServerSetting: userServerSetting ?? this.userServerSetting,
      dynamicColor: dynamicColor ?? this.dynamicColor
    );
  }
}