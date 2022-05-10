import 'package:tare/models/supermarket_category.dart';

class Food {

  final int? id;
  final String name;
  final String? description;
  final bool onHand;
  final SupermarketCategory? supermarketCategory;
  final bool? ignoreShopping;

  Food({
    this.id,
    required this.name,
    this.description,
    required this.onHand,
    this.supermarketCategory,
    this.ignoreShopping
  });

  Food copyWith({
    int? id,
    String? name,
    String? description,
    bool? onHand,
    SupermarketCategory? supermarketCategory,
    bool? ignoreShopping
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      onHand: onHand ?? this.onHand,
      supermarketCategory: supermarketCategory ?? this.supermarketCategory,
      ignoreShopping: ignoreShopping ?? this.ignoreShopping
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        onHand: json['food_onhand'] as bool,
        supermarketCategory: (json['supermarket_category'] != null)
            ? SupermarketCategory.fromJson(json['supermarket_category'])
            : null,
        ignoreShopping: json['ignore_shopping'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? supermarketCategory = this.supermarketCategory != null ? this.supermarketCategory!.toJson() : null;
    
    return {
      'id': this.id,
      'name': this.name,
      'description': this.description ?? '',
      'food_onhand': this.onHand,
      'supermarket_category': supermarketCategory,
      'ignore_shopping': this.ignoreShopping ?? false
    };
  }

  @override
  String toString() => name;
}