// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supermarket_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupermarketCategoryAdapter extends TypeAdapter<SupermarketCategory> {
  @override
  final int typeId = 8;

  @override
  SupermarketCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupermarketCategory(
      id: fields[0] as int?,
      name: fields[1] as String,
      description: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupermarketCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupermarketCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
