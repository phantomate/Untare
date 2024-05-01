// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutritional_value.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionalValueAdapter extends TypeAdapter<NutritionalValue> {
  @override
  final int typeId = 15;

  @override
  NutritionalValue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionalValue(
      id: fields[0] as int?,
      name: fields[1] as String?,
      unit: fields[2] as String?,
      description: fields[3] as String?,
      order: fields[4] as int?,
      totalValue: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionalValue obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.totalValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionalValueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
