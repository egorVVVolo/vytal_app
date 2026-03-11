// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'height_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HeightLogAdapter extends TypeAdapter<HeightLog> {
  @override
  final int typeId = 2;

  @override
  HeightLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HeightLog(
      date: fields[0] as DateTime,
      value: fields[1] as double,
      isMorning: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HeightLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.isMorning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeightLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
