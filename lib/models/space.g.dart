// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpaceAdapter extends TypeAdapter<Space> {
  @override
  final int typeId = 14;

  @override
  Space read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Space(
      id: fields[0] as int?,
      name: fields[1] as String,
      maxRecipes: fields[2] as int,
      maxUsers: fields[3] as int,
      maxFileStorage: fields[4] as int,
      recipeCount: fields[5] as int,
      userCount: fields[6] as int,
      fileStorageCount: fields[7] as int,
      foodInherit: (fields[8] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Space obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.maxRecipes)
      ..writeByte(3)
      ..write(obj.maxUsers)
      ..writeByte(4)
      ..write(obj.maxFileStorage)
      ..writeByte(5)
      ..write(obj.recipeCount)
      ..writeByte(6)
      ..write(obj.userCount)
      ..writeByte(7)
      ..write(obj.fileStorageCount)
      ..writeByte(8)
      ..write(obj.foodInherit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
