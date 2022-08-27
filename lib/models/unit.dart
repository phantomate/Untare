import 'package:hive/hive.dart';

part 'unit.g.dart';

@HiveType(typeId: 7)
class Unit {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final int? recipeCount;

  Unit({
    this.id,
    required this.name,
    this.description,
    this.recipeCount
  });

  Unit copyWith({
    int? id,
    String? name,
    String? description,
    int? recipeCount
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      recipeCount: recipeCount ?? this.recipeCount
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
        id: json['id'] as int?,
        name: json['name'] as String,
        description: json['description'] as String?,
        recipeCount: json['numrecipe'] as int?
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description ?? '',
    'numrecipe': recipeCount ?? 0
  };

  @override
  String toString() => name;
}