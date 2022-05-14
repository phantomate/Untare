import 'package:tare/models/user.dart';

class UserSetting {

  final int user;
  final String defaultUnit;
  final bool useFractions;
  final bool useKj;
  final String searchStyle;
  final List<User> planShare;
  final List<User> shoppingShare;
  final int? ingredientDecimal;
  final bool? comments;
  final bool mealPlanAutoAddShopping;
  final int shoppingRecentDays;


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
      shoppingRecentDays: shoppingRecentDays ?? this.shoppingRecentDays
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      user: json['user'] as int,
      defaultUnit: json['default_unit'] as String,
      useFractions: json['use_fractions'] as bool,
      useKj: json['use_kj'] as bool,
      searchStyle: json['search_style'] as String,
      planShare: json['plan_share'].map((item) => User.fromJson(item)).toList(),
      shoppingShare: json['shopping_share'].map((item) => User.fromJson(item)).toList(),
      ingredientDecimal: json['ingredient_decimals'] as int,
      comments: json['comments'] as bool,
      mealPlanAutoAddShopping: json['mealplan_autoadd_shopping'] as bool,
      shoppingRecentDays: json['shopping_recent_days'] as int,
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
    'shopping_recent_days': this.shoppingRecentDays
  };
}