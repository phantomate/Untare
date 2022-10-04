// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 3;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as int?,
      name: fields[1] as String,
      description: fields[2] as String?,
      image: fields[3] as String?,
      keywords: (fields[4] as List).cast<Keyword>(),
      steps: (fields[5] as List).cast<StepModel>(),
      workingTime: fields[6] as int?,
      waitingTime: fields[7] as int?,
      createdBy: fields[8] as int?,
      createdAt: fields[9] as String?,
      updatedAt: fields[10] as String?,
      internal: fields[11] as bool,
      servings: fields[12] as int?,
      servingsText: fields[13] as String?,
      rating: fields[14] as int?,
      lastCooked: fields[15] as String?,
      isNew: fields[16] as bool?,
      recent: fields[17] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.keywords)
      ..writeByte(5)
      ..write(obj.steps)
      ..writeByte(6)
      ..write(obj.workingTime)
      ..writeByte(7)
      ..write(obj.waitingTime)
      ..writeByte(8)
      ..write(obj.createdBy)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.internal)
      ..writeByte(12)
      ..write(obj.servings)
      ..writeByte(13)
      ..write(obj.servingsText)
      ..writeByte(14)
      ..write(obj.rating)
      ..writeByte(15)
      ..write(obj.lastCooked)
      ..writeByte(16)
      ..write(obj.isNew)
      ..writeByte(17)
      ..write(obj.recent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
