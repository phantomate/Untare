import 'package:tare/models/user.dart';
import 'package:hive/hive.dart';

part 'user_setting.g.dart';

@HiveType(typeId: 2)
class UserSetting {

  @HiveField(0)
  final int user;
  @HiveField(1)
  final String defaultUnit;
  @HiveField(2)
  final bool useFractions;
  @HiveField(3)
  final bool useKj;
  @HiveField(4)
  final String searchStyle;
  @HiveField(5)
  final List<User> planShare;
  @HiveField(6)
  final List<User> shoppingShare;
  @HiveField(7)
  final int? ingredientDecimal;
  @HiveField(8)
  final bool? comments;
  @HiveField(9)
  final bool mealPlanAutoAddShopping;
  @HiveField(10)
  final int shoppingRecentDays;
  @HiveField(11)
  final int shoppingAutoSync;


  UserSetting({
    required this.user,
    required this.defaultUnit,
    required this.useFractions,
    required this.useKj,
    required this.searchStyle,
    required this.planShare,
    required this.shoppingShare,
    required this.ingredientDecimal,
    required this.comments,
    required this.mealPlanAutoAddShopping,
    required this.shoppingRecentDays,
    required this.shoppingAutoSync
  });

  UserSetting copyWith({
    int? user,
    String? defaultUnit,
    bool? useFractions,
    bool? useKj,
    String? searchStyle,
    List<User>? planShare,
    List<User>? shoppingShare,
    int? ingredientDecimal,
    bool? comments,
    bool? mealPlanAutoAddShopping,
    int? shoppingRecentDays,
    int? shoppingAutoSync
  }) {
    return UserSetting(
      user: user ?? this.user,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      useFractions: useFractions ?? this.useFractions,
      useKj: useKj ?? this.useKj,
      searchStyle: searchStyle ?? this.searchStyle,
      planShare: planShare ?? this.planShare,
      shoppingShare: shoppingShare ?? this.shoppingShare,
      ingredientDecimal: ingredientDecimal ?? this.ingredientDecimal,
      comments: comments ?? this.comments,
      mealPlanAutoAddShopping: mealPlanAutoAddShopping ?? this.mealPlanAutoAddShopping,
      shoppingRecentDays: shoppingRecentDays ?? this.shoppingRecentDays,
      shoppingAutoSync: shoppingAutoSync ?? this.shoppingAutoSync
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      user: json['user'] as int,
      defaultUnit: json['default_unit'] as String,
      useFractions: json['use_fractions'] as bool,
      useKj: json['use_kj'] as bool,
      searchStyle: json['search_style'] as String,
      planShare: json['plan_share'].map((item) => User.fromJson(item)).toList().cast<User>(),
      shoppingShare: json['shopping_share'].map((item) => User.fromJson(item)).toList().cast<User>(),
      ingredientDecimal: json['ingredient_decimals'] as int,
      comments: json['comments'] as bool,
      mealPlanAutoAddShopping: json['mealplan_autoadd_shopping'] as bool,
      shoppingRecentDays: json['shopping_recent_days'] as int,
      shoppingAutoSync: json['shopping_auto_sync'] as int
    );
  }

  Map<String, dynamic> toJson() => {
    'user': this.user,
    'default_unit': this.defaultUnit,
    'use_fractions': this.useFractions,
    'use_kj': this.useKj,
    'search_style': this.searchStyle,
    'shopping_share': this.shoppingShare,
    'ingredient_decimals': this.ingredientDecimal,
    'comments': this.comments,
    'mealplan_autoadd_shopping': this.mealPlanAutoAddShopping,
    'shopping_recent_days': this.shoppingRecentDays,
    'shopping_auto_sync': this.shoppingAutoSync
  };
}