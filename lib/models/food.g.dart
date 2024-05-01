// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final int typeId = 6;

  @override
  Food read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food(
      id: fields[0] as int?,
      name: fields[1] as String,
      description: fields[2] as String?,
      onHand: fields[3] as bool?,
      supermarketCategory: fields[4] as SupermarketCategory?,
      ignoreShopping: fields[5] as bool?,
      recipeCount: fields[6] as int?,
      pluralName: fields[7] as String?,
      recipe: fields[8] as Recipe?,
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.onHand)
      ..writeByte(4)
      ..write(obj.supermarketCategory)
      ..writeByte(5)
      ..write(obj.ignoreShopping)
      ..writeByte(6)
      ..write(obj.recipeCount)
      ..writeByte(7)
      ..write(obj.pluralName)
      ..writeByte(8)
      ..write(obj.recipe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
