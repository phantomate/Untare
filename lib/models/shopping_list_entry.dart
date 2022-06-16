import 'package:tare/models/food.dart';
import 'package:tare/models/recipe_meal_plan.dart';
import 'package:tare/models/unit.dart';
import 'package:hive/hive.dart';

part 'shopping_list_entry.g.dart';

@HiveType(typeId: 11)
class ShoppingListEntry {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int? listRecipe;
  @HiveField(2)
  final Food? food;
  @HiveField(3)
  final Unit? unit;
  @HiveField(4)
  final int? ingredient;
  @HiveField(5)
  final String? ingredientNote;
  @HiveField(6)
  final double amount;
  @HiveField(7)
  final int? order;
  @HiveField(8)
  final bool checked;
  @HiveField(9)
  final RecipeMealPlan? recipeMealPlan;
  @HiveField(10)
  final int? createdBy;
  @HiveField(11)
  final String? createdAt;
  @HiveField(12)
  final String? completedAt;
  @HiveField(13)
  final String? delayUntil;


  ShoppingListEntry({
    this.id,
    this.listRecipe,
    this.food,
    this.unit,
    this.ingredient,
    this.ingredientNote,
    required this.amount,
    this.order,
    required this.checked,
    this.recipeMealPlan,
    this.createdBy,
    this.createdAt,
    this.completedAt,
    this.delayUntil
  });

  ShoppingListEntry copyWith({
    int? id,
    int? listRecipe,
    Food? food,
    Unit? unit,
    int? ingredient,
    String? ingredientNote,
    double? amount,
    int? order,
    bool? checked,
    RecipeMealPlan? recipeMealPlan,
    String? createdAt,
    String? completedAt,
    String? delayUntil
  }) {
    return ShoppingListEntry(
        id: id ?? this.id,
        listRecipe: listRecipe ?? this.listRecipe,
        food: food ?? this.food,
        unit: unit ?? this.unit,
        ingredient: ingredient ?? this.ingredient,
        ingredientNote: ingredientNote ?? this.ingredientNote,
        amount: amount ?? this.amount,
        order: order ?? this.order,
        checked: checked ?? this.checked,
        recipeMealPlan: recipeMealPlan ?? this.recipeMealPlan,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
        delayUntil: delayUntil ?? this.delayUntil
    );
  }

  factory ShoppingListEntry.fromJson(Map<String, dynamic> json) {
    return ShoppingListEntry(
        id: json['id'] as int,
        listRecipe: json['list_recipe'] as int?,
        food: (json['food'] != null)
            ? Food.fromJson(json['food'])
            : null,
        unit: (json['unit'] != null)
            ? Unit.fromJson(json['unit'])
            : null,
        ingredient: json['ingredient'] as int?,
        ingredientNote: json['ingredient_note'] as String?,
        amount: json['amount'] as double,
        order: json['order'] as int,
        checked: json['checked'] as bool,
        recipeMealPlan: (json['recipe_mealplan'] != null)
            ? RecipeMealPlan.fromJson(json['recipe_mealplan'])
            : null,
        createdBy: json['created_by']['id'] as int,
        createdAt: json['created_at'] as String,
        completedAt: json['completed_at'] as String?,
        delayUntil: json['delay_until'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? unit = this.unit != null ? this.unit!.toJson() : null;
    Map<String, dynamic>? food = this.food != null ? this.food!.toJson() : null;

    return {
      'id': this.id,
      'list_recipe': this.listRecipe,
      'food': food,
      'unit': unit,
      'ingredient': this.ingredient,
      'amount': this.amount,
      'order': this.order ?? 0,
      'checked': this.checked,
      'completed_at': this.completedAt,
      'delay_until': this.delayUntil
    };
  }
}