// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseSetAdapter extends TypeAdapter<ExerciseSet> {
  @override
  final int typeId = 6;

  @override
  ExerciseSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSet(
      id: fields[0] as String?,
      weight: fields[1] as double,
      weightUnit: fields[2] as String,
      reps: fields[3] as int,
      rpe: fields[4] as double?,
      isWarmup: fields[5] as bool,
      isDropSet: fields[6] as bool,
      notes: fields[7] as String?,
      completed: fields[8] as bool,
      timestamp: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.weightUnit)
      ..writeByte(3)
      ..write(obj.reps)
      ..writeByte(4)
      ..write(obj.rpe)
      ..writeByte(5)
      ..write(obj.isWarmup)
      ..writeByte(6)
      ..write(obj.isDropSet)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.completed)
      ..writeByte(9)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
