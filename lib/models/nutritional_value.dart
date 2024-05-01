import 'package:hive/hive.dart';

part 'nutritional_value.g.dart';

@HiveType(typeId: 15)
class NutritionalValue {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? unit;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final int? order;
  @HiveField(5)
  final double? totalValue;

  NutritionalValue({
    this.id,
    this.name,
    this.unit,
    this.description,
    this.order,
    this.totalValue
  });

  NutritionalValue copyWith({
    int? id,
    String? name,
    String? unit,
    String? description,
    int? order,
    double? totalValue
  }) {
    return NutritionalValue(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      order: order ?? this.order,
      totalValue: totalValue ?? this.totalValue
    );
  }

  factory NutritionalValue.fromJson(Map<String, dynamic> json) {
    return NutritionalValue(
        id: json['id'] as int?,
        name: json['name'] as String?,
        unit: json['unit'] as String?,
        description: json['description'] as String?,
        order: json['order'] as int?,
        totalValue: ((json['total_value'] == json['total_value'].toInt()) ? json['total_value'].roundToDouble() : json['total_value']) as double?
    );
  }

  @override
  String toString() => name ?? '';
}