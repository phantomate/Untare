import 'package:tare/models/supermarket_category.dart';
import 'package:hive/hive.dart';

part 'food.g.dart';

@HiveType(typeId: 6)
class Food {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final bool onHand;
  @HiveField(4)
  final SupermarketCategory? supermarketCategory;
  @HiveField(5)
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