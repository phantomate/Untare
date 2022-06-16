// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingAdapter extends TypeAdapter<AppSetting> {
  @override
  final int typeId = 1;

  @override
  AppSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSetting(
      layout: fields[0] as String,
      theme: fields[1] as String,
      defaultPage: fields[2] as String,
      userServerSetting: fields[3] as UserSetting?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSetting obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.layout)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.defaultPage)
      ..writeByte(3)
      ..write(obj.userServerSetting);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
