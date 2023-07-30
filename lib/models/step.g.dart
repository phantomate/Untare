// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepModelAdapter extends TypeAdapter<StepModel> {
  @override
  final int typeId = 4;

  @override
  StepModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      instruction: fields[2] as String?,
      ingredients: (fields[3] as List).cast<Ingredient>(),
      ingredientsMarkdown: fields[4] as String?,
      ingredientsVue: fields[5] as String?,
      time: fields[6] as int?,
      order: fields[7] as int?,
      stepRecipe: fields[8] as int?,
      stepRecipeData: fields[9] as Recipe?,
    );
  }

  @override
  void write(BinaryWriter writer, StepModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.instruction)
      ..writeByte(3)
      ..write(obj.ingredients)
      ..writeByte(4)
      ..write(obj.ingredientsMarkdown)
      ..writeByte(5)
      ..write(obj.ingredientsVue)
      ..writeByte(6)
      ..write(obj.time)
      ..writeByte(7)
      ..write(obj.order)
      ..writeByte(8)
      ..write(obj.stepRecipe)
      ..writeByte(9)
      ..write(obj.stepRecipeData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
