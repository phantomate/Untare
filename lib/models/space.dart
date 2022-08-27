import 'package:hive/hive.dart';

part 'space.g.dart';

@HiveType(typeId: 14)
class Space {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int maxRecipes;
  @HiveField(3)
  final int maxUsers;
  @HiveField(4)
  final int maxFileStorage;
  @HiveField(5)
  final int recipeCount;
  @HiveField(6)
  final int userCount;
  @HiveField(7)
  final int fileStorageCount;
  @HiveField(8)
  final List foodInherit;

  Space({
    this.id,
    required this.name,
    required this.maxRecipes,
    required this.maxUsers,
    required this.maxFileStorage,
    required this.recipeCount,
    required this.userCount,
    required this.fileStorageCount,
    required this.foodInherit
  });

  Space copyWith({
    int? id,
    String? name,
    int? maxRecipes,
    int? maxUsers,
    int? maxFileStorage,
    int? recipeCount,
    int? userCount,
    int? fileStorageCount,
    List? foodInherit
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      maxRecipes: maxRecipes ?? this.maxRecipes,
      maxUsers: maxUsers ?? this.maxUsers,
      maxFileStorage: maxFileStorage ?? this.maxFileStorage,
      recipeCount: recipeCount ?? this.recipeCount,
      userCount: userCount ?? this.userCount,
      fileStorageCount: fileStorageCount ?? this.fileStorageCount,
      foodInherit: foodInherit ?? this.foodInherit
    );
  }

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as int?,
      name: json['name'] as String,
      maxRecipes: json['max_recipes'] as int,
      maxUsers: json['max_users'] as int,
      maxFileStorage: json['max_file_storage_mb'] as int,
      recipeCount: json['recipe_count'] as int,
      userCount: json['user_count'] as int,
      fileStorageCount: json['file_size_mb'] as int,
      foodInherit: json['food_inherit'] as List,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'max_recipes': maxRecipes,
      'max_users': maxUsers,
      'max_file_storage_mb': maxFileStorage,
      'recipe_count': recipeCount,
      'user_count': userCount,
      'file_size_mb': fileStorageCount,
      'food_inherit': foodInherit
    };
  }
}