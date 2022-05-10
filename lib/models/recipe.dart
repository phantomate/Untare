import 'package:tare/models/step.dart';

class Recipe {

  final int? id;
  final String name;
  final String? description;
  final String? image;
  final List keywords;
  final steps;
  final int? workingTime;
  final int? waitingTime;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final bool internal;
  final int? servings;
  final String? servingsText;
  final int? rating;
  final String? lastCooked;
  final bool? isNew;
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
    List? keywords,
    steps,
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

    if (this.steps != null && this.steps.isNotEmpty) {
      this.steps.forEach((StepModel step) {
        steps.add(step.toJson());
      });
    }

    return {
      'id': this.id,
      'name': this.name,
      'description': this.description,
      'keywords': this.keywords,
      'steps': steps,
      'working_time': this.workingTime ?? 0,
      'waiting_time': this.waitingTime ?? 0,
      'internal': this.internal,
      'servings': this.servings ?? 0,
      'servings_text': this.servingsText ?? ''
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      keywords: json['keywords'] as List,
      steps: (json['steps'] != null) ? json['steps'].map((item) => StepModel.fromJson(item)) : null,
      workingTime: json['working_time'] as int?,
      waitingTime: json['waiting_time'] as int?,
      createdBy: json['created_by'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      internal: json['internal'] as bool,
      servings: json['servings'] as int?,
      servingsText: json['servings_text'] as String,
      rating: json['rating'] as int?,
      lastCooked: json['last_cooked'] as String?,
      isNew: json['new'] as bool?,
      recent: json['recent'] as int?
    );
  }
}