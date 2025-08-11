// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressionSettingsAdapter extends TypeAdapter<ProgressionSettings> {
  @override
  final int typeId = 8;

  @override
  ProgressionSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressionSettings(
      weightIncrementKg: fields[0] as double,
      progressionStrategy: fields[1] as String, // Fixed: Changed from 2 to 1
      minRepsBeforeWeightIncrease: fields[2] as int, // Fixed: Changed from 3 to 2
      plateauThreshold: fields[3] as int, // Fixed: Changed from 4 to 3
      deloadPercentage: fields[4] as double, // Fixed: Changed from 5 to 4
      defaultRestTimeSeconds: fields[5] as int, // Fixed: Changed from 6 to 5
    );
  }

  @override
  void write(BinaryWriter writer, ProgressionSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.weightIncrementKg)
      ..writeByte(1) // Fixed: Changed from 2 to 1
      ..write(obj.progressionStrategy)
      ..writeByte(2) // Fixed: Changed from 3 to 2
      ..write(obj.minRepsBeforeWeightIncrease)
      ..writeByte(3) // Fixed: Changed from 4 to 3
      ..write(obj.plateauThreshold)
      ..writeByte(4) // Fixed: Changed from 5 to 4
      ..write(obj.deloadPercentage)
      ..writeByte(5) // Fixed: Changed from 6 to 5
      ..write(obj.defaultRestTimeSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
