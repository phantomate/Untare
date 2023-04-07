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
  @HiveField(4)
  final String? pluralName;

  Unit({
    this.id,
    required this.name,
    this.description,
    this.recipeCount,
    this.pluralName
  });

  Unit copyWith({
    int? id,
    String? name,
    String? description,
    int? recipeCount,
    String? pluralName
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      recipeCount: recipeCount ?? this.recipeCount,
      pluralName: pluralName ?? this.pluralName
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
        id: json['id'] as int?,
        name: json['name'] as String,
        description: json['description'] as String?,
        recipeCount: json['numrecipe'] as int?,
        pluralName: json['plural_name'] as String?
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description ?? '',
    'numrecipe': recipeCount ?? 0,
    'plural_name': pluralName
  };

  String getUnitName (double amount) {
    if (amount > 1 && pluralName != null && pluralName != '') {
      return pluralName!;
    }

    return name;
  }

  @override
  String toString() => name;
}