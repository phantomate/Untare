import 'package:hive/hive.dart';

part 'meal_type.g.dart';

@HiveType(typeId: 10)
class MealType {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int order;
  @HiveField(3)
  final String? icon;
  @HiveField(4)
  final String? color;
  @HiveField(5)
  final bool defaultType;
  @HiveField(6)
  final int createdBy;

  MealType({
    this.id,
    required this.name,
    required this.order,
    this.icon,
    this.color,
    required this.defaultType,
    required this.createdBy
  });

  MealType copyWith({
    int? id,
    String? name,
    int? order,
    String? icon,
    String? color,
    bool? defaultType,
    int? createdBy
  }) {
    return MealType(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      defaultType: defaultType ?? this.defaultType,
      createdBy: createdBy ?? this.createdBy
    );
  }

  factory MealType.fromJson(Map<String, dynamic> json) {
    return MealType(
      id: json['id'] as int,
      name: json['name'] as String,
      order: json['order'] as int,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      defaultType: json['default'] as bool,
      createdBy: json['created_by'] as int
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'order': order,
    'icon': icon,
    'color': color,
    'default': defaultType
  };
}