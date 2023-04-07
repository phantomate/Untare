import 'package:untare/models/supermarket_category.dart';
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
  final bool? onHand;
  @HiveField(4)
  final SupermarketCategory? supermarketCategory;
  @HiveField(5)
  final bool? ignoreShopping;
  @HiveField(6)
  final int? recipeCount;
  @HiveField(7)
  final String? pluralName;

  Food({
    this.id,
    required this.name,
    this.description,
    this.onHand,
    this.supermarketCategory,
    this.ignoreShopping,
    this.recipeCount,
    this.pluralName
  });

  Food copyWith({
    int? id,
    String? name,
    String? description,
    bool? onHand,
    SupermarketCategory? supermarketCategory,
    bool? ignoreShopping,
    int? recipeCount,
    String? pluralName
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      onHand: onHand ?? this.onHand,
      supermarketCategory: supermarketCategory ?? this.supermarketCategory,
      ignoreShopping: ignoreShopping ?? this.ignoreShopping,
      recipeCount: recipeCount ?? this.recipeCount,
      pluralName: pluralName ?? this.pluralName
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
        id: json['id'] as int?,
        name: json['name'] as String,
        description: json['description'] as String?,
        onHand: json['food_onhand'] as bool?,
        supermarketCategory: (json['supermarket_category'] != null)
            ? SupermarketCategory.fromJson(json['supermarket_category'])
            : null,
        ignoreShopping: json['ignore_shopping'] as bool?,
        recipeCount: json['numrecipe'] as int?,
        pluralName: json['plural_name'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? supermarketCategory = this.supermarketCategory != null ? this.supermarketCategory!.toJson() : null;
    
    return {
      'id': id,
      'name': name,
      'description': description ?? '',
      'food_onhand': onHand,
      'supermarket_category': supermarketCategory,
      'ignore_shopping': ignoreShopping ?? false,
      'numrecipe': recipeCount,
      'plural_name': pluralName
    };
  }

  String getFoodName (double amount) {
    if (amount > 1 && pluralName != null && pluralName != '') {
      return pluralName!;
    }

    return name;
  }

  @override
  String toString() => name;
}