// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListEntryAdapter extends TypeAdapter<ShoppingListEntry> {
  @override
  final int typeId = 11;

  @override
  ShoppingListEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListEntry(
      id: fields[0] as int?,
      listRecipe: fields[1] as int?,
      food: fields[2] as Food?,
      unit: fields[3] as Unit?,
      ingredient: fields[4] as int?,
      ingredientNote: fields[5] as String?,
      amount: fields[6] as double,
      order: fields[7] as int?,
      checked: fields[8] as bool,
      recipeMealPlan: fields[9] as RecipeMealPlan?,
      createdBy: fields[10] as int?,
      createdAt: fields[11] as String?,
      completedAt: fields[12] as String?,
      delayUntil: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListEntry obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listRecipe)
      ..writeByte(2)
      ..write(obj.food)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.ingredient)
      ..writeByte(5)
      ..write(obj.ingredientNote)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.order)
      ..writeByte(8)
      ..write(obj.checked)
      ..writeByte(9)
      ..write(obj.recipeMealPlan)
      ..writeByte(10)
      ..write(obj.createdBy)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.delayUntil);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
