class RecipeMealPlan {

  final int? id;
  final String recipeName;
  final String name;
  final int recipe;
  final int? mealPlan;
  final int servings;
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
        servings: json['servings'] as int,
        mealPlanNote: json['mealplan_note'] as String?
    );
  }
}