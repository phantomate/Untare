// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_meal_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeMealPlanAdapter extends TypeAdapter<RecipeMealPlan> {
  @override
  final int typeId = 12;

  @override
  RecipeMealPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeMealPlan(
      id: fields[0] as int?,
      recipeName: fields[1] as String,
      name: fields[2] as String,
      recipe: fields[3] as int,
      mealPlan: fields[4] as int?,
      servings: fields[5] as int,
      mealPlanNote: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeMealPlan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recipeName)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.recipe)
      ..writeByte(4)
      ..write(obj.mealPlan)
      ..writeByte(5)
      ..write(obj.servings)
      ..writeByte(6)
      ..write(obj.mealPlanNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeMealPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
