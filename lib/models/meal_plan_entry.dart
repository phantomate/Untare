import 'package:untare/models/meal_type.dart';
import 'package:untare/models/recipe.dart';
import 'package:hive/hive.dart';
import 'package:untare/models/user.dart';

part 'meal_plan_entry.g.dart';

@HiveType(typeId: 9)
class MealPlanEntry {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final Recipe? recipe;
  @HiveField(3)
  final int servings;
  @HiveField(4)
  final String note;
  @HiveField(5)
  final String? noteMarkdown;
  @HiveField(6)
  final String date;
  @HiveField(7)
  final MealType mealType;
  @HiveField(8)
  final int? createdBy;
  @HiveField(9)
  final List<User> shared;
  @HiveField(10)
  final String? recipeName;
  @HiveField(11)
  final String? mealTypeName;
  @HiveField(12)
  final bool? shopping;

  MealPlanEntry({
    this.id,
    required this.title,
    this.recipe,
    required this.servings,
    required this.note,
    this.noteMarkdown,
    required this.date,
    required this.mealType,
    this.createdBy,
    required this.shared,
    this.recipeName,
    this.mealTypeName,
    this.shopping
  });

  MealPlanEntry copyWith({
    int? id,
    String? title,
    Recipe? recipe,
    int? servings,
    String? note,
    String? noteMarkdown,
    String? date,
    MealType? mealType,
    int? createdBy,
    List<User>? shared,
    String? recipeName,
    String? mealTypeName,
    bool? shopping
  }) {
    return MealPlanEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      recipe: recipe ?? this.recipe,
      servings: servings ?? this.servings,
      note: note ?? this.note,
      noteMarkdown: noteMarkdown ?? this.noteMarkdown,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      createdBy: createdBy ?? this.createdBy,
      shared: shared ?? this.shared,
      recipeName: recipeName ?? this.recipeName,
      mealTypeName: mealTypeName ?? this.mealTypeName,
      shopping: shopping ?? this.shopping
    );
  }

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) {
    return MealPlanEntry(
      id: json['id'] as int,
      title: json['title'] as String,
      recipe: (json['recipe'] != null) ? Recipe.fromJson(json['recipe']) : null,
      servings: (json['servings'] is int) ? json['servings'] : ((json['servings'] is double) ? json['servings'].toInt() : 1),
      note: json['note'] as String,
      noteMarkdown: json['note_markdown'] as String,
      date: json['date'] as String,
      mealType: MealType.fromJson(json['meal_type']),
      createdBy: json['created_by'] as int,
      shared: json['shared'].map((item) => User.fromJson(item)).toList().cast<User>(),
      recipeName: json['recipe_name'] as String?,
      mealTypeName: json['meal_type_name'] as String?,
      shopping: json['shopping'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? recipe = this.recipe != null ? this.recipe!.toJson() : null;

    List<Map<String,dynamic>> sharedList = [];
    if (shared.isNotEmpty) {
      for (var share in shared) {
        sharedList.add(share.toJson());
      }
    }

    return {
      'id': id,
      'title': title,
      'recipe': recipe,
      'servings': servings,
      'note': note,
      'date': date,
      'meal_type': mealType.toJson(),
      'shared': sharedList
    };
  }
}