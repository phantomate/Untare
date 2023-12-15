import 'package:untare/models/unit.dart';
import 'food.dart';
import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 5)
class Ingredient {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final Food? food;
  @HiveField(2)
  final Unit? unit;
  @HiveField(3)
  final double amount;
  @HiveField(4)
  final String? note;
  @HiveField(5)
  final int? order;
  @HiveField(6)
  final String? originalText;

  Ingredient({
    this.id,
    this.food,
    this.unit,
    required this.amount,
    this.note,
    this.order,
    this.originalText
  });

  Ingredient copyWith({
    int? id,
    Food? food,
    Unit? unit,
    double? amount,
    String? note,
    int? order,
    String? originalText,
  }) {
    return Ingredient(
        id: id ?? this.id,
        food: food ?? this.food,
        unit: unit ?? this.unit,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        order: order ?? this.order,
        originalText: originalText ?? this.originalText
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? unit = this.unit?.toJson();
    Map<String, dynamic>? food = this.food?.toJson();

    return {
      'id': id,
      'food': food,
      'unit': unit,
      'amount': amount,
      'note': note,
      'order': order,
      'original_text': originalText
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int?,
      food: (json['food'] != null) ? Food.fromJson(json['food']) : null,
      unit: (json['unit'] != null) ? Unit.fromJson(json['unit']) : null,
      amount: (json['amount'] is int) ? json['amount'].toDouble() : json['amount'],
      note: json['note'] as String?,
      order: json['order'] as int?,
      originalText: json['original_text'] as String?,
    );
  }
}