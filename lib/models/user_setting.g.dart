// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingAdapter extends TypeAdapter<UserSetting> {
  @override
  final int typeId = 2;

  @override
  UserSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSetting(
      user: fields[0] as int,
      defaultUnit: fields[1] as String,
      useFractions: fields[2] as bool,
      useKj: fields[3] as bool,
      planShare: (fields[4] as List).cast<User>(),
      shoppingShare: (fields[5] as List).cast<User>(),
      ingredientDecimal: fields[6] as int?,
      comments: fields[7] as bool?,
      mealPlanAutoAddShopping: fields[8] as bool,
      shoppingRecentDays: fields[9] as int,
      shoppingAutoSync: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserSetting obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.user)
      ..writeByte(1)
      ..write(obj.defaultUnit)
      ..writeByte(2)
      ..write(obj.useFractions)
      ..writeByte(3)
      ..write(obj.useKj)
      ..writeByte(4)
      ..write(obj.planShare)
      ..writeByte(5)
      ..write(obj.shoppingShare)
      ..writeByte(6)
      ..write(obj.ingredientDecimal)
      ..writeByte(7)
      ..write(obj.comments)
      ..writeByte(8)
      ..write(obj.mealPlanAutoAddShopping)
      ..writeByte(9)
      ..write(obj.shoppingRecentDays)
      ..writeByte(10)
      ..write(obj.shoppingAutoSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
