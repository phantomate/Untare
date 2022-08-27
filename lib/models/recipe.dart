import 'package:untare/models/keyword.dart';
import 'package:untare/models/step.dart';
import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 3)
class Recipe {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String? image;
  @HiveField(4)
  final List<Keyword> keywords;
  @HiveField(5)
  final List<StepModel> steps;
  @HiveField(6)
  final int? workingTime;
  @HiveField(7)
  final int? waitingTime;
  @HiveField(8)
  final int? createdBy;
  @HiveField(9)
  final String? createdAt;
  @HiveField(10)
  final String? updatedAt;
  @HiveField(11)
  final bool internal;
  @HiveField(12)
  final int? servings;
  @HiveField(13)
  final String? servingsText;
  @HiveField(14)
  final int? rating;
  @HiveField(15)
  final String? lastCooked;
  @HiveField(16)
  final bool? isNew;
  @HiveField(17)
  final int? recent;

  Recipe({
    this.id,
    required this.name,
    this.description,
    this.image,
    required this.keywords,
    required this.steps,
    this.workingTime,
    this.waitingTime,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    required this.internal,
    this.servings,
    this.servingsText,
    this.rating,
    this.lastCooked,
    this.isNew,
    this.recent
  });

  Recipe copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    List<Keyword>? keywords,
    List<StepModel>? steps,
    int? workingTime,
    int? waitingTime,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
    bool? internal,
    int? servings,
    String? servingsText,
    int? rating,
    String? lastCooked,
    bool? isNew,
    int? recent
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      keywords: keywords ?? this.keywords,
      steps: steps ?? this.steps,
      workingTime: workingTime ?? this.workingTime,
      waitingTime: waitingTime ?? this.waitingTime,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      internal: internal ?? this.internal,
      servings: servings ?? this.servings,
      servingsText: servingsText ?? this.servingsText,
      rating: rating ?? this.rating,
      lastCooked: lastCooked ?? this.lastCooked,
      isNew: isNew ?? this.isNew,
      recent: recent ?? this.recent
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String,dynamic>> steps = [];
    List<Map<String,dynamic>> keywords = [];

    if (this.steps.isNotEmpty) {
      for (var step in this.steps) {
        steps.add(step.toJson());
      }
    }

    if (this.keywords.isNotEmpty) {
      for (var keyword in this.keywords) {
        keywords.add(keyword.toJson());
      }
    }

    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'keywords': keywords,
      'steps': steps,
      'working_time': workingTime ?? 0,
      'waiting_time': waitingTime ?? 0,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'internal': internal,
      'servings': servings ?? 0,
      'servings_text': servingsText ?? '',
      'rating': rating,
      'last_cooked': lastCooked,
      'is_new': isNew,
      'recent': recent
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      keywords: (json['keywords'] != null && json['keywords'].isNotEmpty) ? json['keywords'].map((item) => Keyword.fromJson(item)).toList().cast<Keyword>() : [],
      steps: (json['steps'] != null) ? json['steps'].map((item) => StepModel.fromJson(item)).toList().cast<StepModel>() : [],
      workingTime: (json['working_time'] is double) ? json['working_time'].toInt() : json['working_time'] as int?,
      waitingTime: (json['waiting_time'] is double) ? json['waiting_time'].toInt() : json['waiting_time'] as int?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      internal: json['internal'] as bool,
      servings: (json['servings'] is int) ? json['servings'] : ((json['servings'] is double) ? json['servings'].toInt() : null),
      servingsText: json['servings_text'] as String?,
      rating: (json['rating'] is int) ? json['rating'] : ((json['rating'] is double) ? json['rating'].toInt() : null),
      lastCooked: json['last_cooked'] as String?,
      isNew: json['new'] as bool?,
      recent: json['recent'] as int?
    );
  }
}