import 'package:untare/models/ingredient.dart';
import 'package:hive/hive.dart';
import 'package:untare/models/recipe.dart';

part 'step.g.dart';

@HiveType(typeId: 4)
class StepModel {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? instruction;
  @HiveField(3)
  final List<Ingredient> ingredients;
  @HiveField(6)
  final int? time;
  @HiveField(7)
  final int? order;
  @HiveField(8)
  final int? stepRecipe;
  @HiveField(9)
  final Recipe? stepRecipeData;
  @HiveField(10)
  final String? instructionsMarkdown;

  StepModel({
    this.id,
    this.name,
    this.instruction,
    required this.ingredients,
    this.instructionsMarkdown,
    this.time,
    this.order,
    this.stepRecipe,
    this.stepRecipeData
  });

  StepModel copyWith({
    int? id,
    String? name,
    String? instruction,
    List<Ingredient>? ingredients,
    String? instructionsMarkdown,
    int? time,
    int? order,
    int? stepRecipe,
    Recipe? stepRecipeData
  }) {
    return StepModel(
      id: id ?? this.id,
      name: name ?? this.name,
      instruction: instruction ?? this.instruction,
      ingredients: ingredients ?? this.ingredients,
      instructionsMarkdown: instructionsMarkdown ?? this.instructionsMarkdown,
      time: time ?? this.time,
      order: order ?? this.order,
      stepRecipe: stepRecipe ?? this.stepRecipe,
      stepRecipeData: stepRecipeData ?? this.stepRecipeData
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String,dynamic>> ingredients = [];

    if (this.ingredients.isNotEmpty) {
      for (var ingredient in this.ingredients) {
        ingredients.add(ingredient.toJson());
      }
    }

    return {
      'id': id,
      'name': name ?? '',
      'instruction': instruction ?? '',
      'ingredients': ingredients,
      'time': time ?? 0,
      'order': order ?? 0,
      'step_recipe': stepRecipe
    };
  }

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      instruction: json['instruction'] as String?,
      ingredients: json['ingredients'].map((item) => Ingredient.fromJson(item)).toList().cast<Ingredient>(),
      instructionsMarkdown: json['instructions_markdown'] as String?,
      time: json['time'] as int?,
      order: json['order'] as int?,
      stepRecipe: json['step_recipe'] as int?,
      stepRecipeData: (json['step_recipe_data'] != null) ? Recipe.fromJson(json['step_recipe_data']) : null
    );
  }
}