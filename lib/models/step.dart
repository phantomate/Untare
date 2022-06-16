import 'package:tare/models/ingredient.dart';
import 'package:hive/hive.dart';

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
  @HiveField(4)
  final String? ingredientsMarkdown;
  @HiveField(5)
  final String? ingredientsVue;
  @HiveField(6)
  final int? time;
  @HiveField(7)
  final int? order;

  StepModel({
    this.id,
    this.name,
    this.instruction,
    required this.ingredients,
    this.ingredientsMarkdown,
    this.ingredientsVue,
    this.time,
    this.order
  });

  StepModel copyWith({
    int? id,
    String? name,
    String? instruction,
    List<Ingredient>? ingredients,
    String? ingredientsMarkdown,
    String? ingredientsVue,
    int? time,
    int? order,
  }) {
    return StepModel(
      id: id ?? this.id,
      name: name ?? this.name,
      instruction: instruction ?? this.instruction,
      ingredients: ingredients ?? this.ingredients,
      ingredientsMarkdown: ingredientsMarkdown ?? this.ingredientsMarkdown,
      ingredientsVue: ingredientsVue ?? this.ingredientsVue,
      time: time ?? this.time,
      order: order ?? this.order
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String,dynamic>> ingredients = [];

    if (this.ingredients.isNotEmpty) {
      this.ingredients.forEach((Ingredient ingredient) {
        ingredients.add(ingredient.toJson());
      });
    }

    return {
      'id': this.id,
      'name': this.name ?? '',
      'instruction': this.instruction ?? '',
      'ingredients': ingredients,
      'time': this.time ?? 0,
      'order': this.order ?? 0
    };
  }

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      instruction: json['instruction'] as String?,
      ingredients: json['ingredients'].map((item) => Ingredient.fromJson(item)).toList().cast<Ingredient>(),
      ingredientsMarkdown: json['ingredients_markdown'] as String?,
      ingredientsVue: json['ingredients_vue'] as String?,
      time: json['time'] as int?,
      order: json['order'] as int?,
    );
  }
}