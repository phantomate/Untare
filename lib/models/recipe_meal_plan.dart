import 'package:hive/hive.dart';

part 'recipe_meal_plan.g.dart';

@HiveType(typeId: 12)
class RecipeMealPlan {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String recipeName;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final int recipe;
  @HiveField(4)
  final int? mealPlan;
  @HiveField(5)
  final int servings;
  @HiveField(6)
  final String? mealPlanNote;

  RecipeMealPlan({
    this.id,
    required this.recipeName,
    required this.name,
    required this.recipe,
    this.mealPlan,
    required this.servings,
    this.mealPlanNote
  });

  factory RecipeMealPlan.fromJson(Map<String, dynamic> json) {
    return RecipeMealPlan(
        id: json['id'] as int,
        recipeName: json['recipe_name'] as String,
        name: json['name'] as String,
        recipe: json['recipe'] as int,
        mealPlan: json['mealplan'] as int?,
        servings: (json['servings'] is int) ? json['servings'] : ((json['servings'] is double) ? json['servings'].toInt() : 1),
        mealPlanNote: json['mealplan_note'] as String?
    );
  }
}