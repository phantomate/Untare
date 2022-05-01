import 'package:tare/models/unit.dart';

import 'food.dart';

class Ingredient {

  final int? id;
  final Food? food;
  final Unit? unit;
  final double amount;
  final String? note;
  final int order;
  final String? originalText;

  Ingredient({
    this.id,
    this.food,
    this.unit,
    required this.amount,
    this.note,
    required this.order,
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
    Map<String, dynamic>? unit = this.unit != null ? this.unit!.toJson() : null;
    Map<String, dynamic>? food = this.unit != null ? this.food!.toJson() : null;

    return {
      'id': this.id,
      'food': food,
      'unit': unit,
      'amount': this.amount,
      'note': this.note,
      'order': this.order,
      'original_text': this.originalText
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      food: (json['food'] != null) ? Food.fromJson(json['food']) : null,
      unit: (json['unit'] != null) ? Unit.fromJson(json['unit']) : null,
      amount: json['amount'] as double,
      note: json['note'] as String?,
      order: json['order'] as int,
      originalText: json['original_text'] as String?,
    );
  }
}