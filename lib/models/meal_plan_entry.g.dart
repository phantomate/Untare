// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealPlanEntryAdapter extends TypeAdapter<MealPlanEntry> {
  @override
  final int typeId = 9;

  @override
  MealPlanEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlanEntry(
      id: fields[0] as int?,
      title: fields[1] as String,
      recipe: fields[2] as Recipe?,
      servings: fields[3] as int,
      note: fields[4] as String,
      noteMarkdown: fields[5] as String?,
      mealType: fields[6] as MealType,
      createdBy: fields[7] as int?,
      shared: (fields[8] as List).cast<User>(),
      recipeName: fields[9] as String?,
      mealTypeName: fields[10] as String?,
      shopping: fields[11] as bool?,
      fromDate: fields[12] as String?,
      toDate: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealPlanEntry obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.recipe)
      ..writeByte(3)
      ..write(obj.servings)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.noteMarkdown)
      ..writeByte(6)
      ..write(obj.mealType)
      ..writeByte(7)
      ..write(obj.createdBy)
      ..writeByte(8)
      ..write(obj.shared)
      ..writeByte(9)
      ..write(obj.recipeName)
      ..writeByte(10)
      ..write(obj.mealTypeName)
      ..writeByte(11)
      ..write(obj.shopping)
      ..writeByte(12)
      ..write(obj.fromDate)
      ..writeByte(13)
      ..write(obj.toDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
