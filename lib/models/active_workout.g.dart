// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActiveWorkoutAdapter extends TypeAdapter<ActiveWorkout> {
  @override
  final int typeId = 5;

  @override
  ActiveWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActiveWorkout(
      id: fields[0] as String,
      name: fields[2] as String,
      splitId: fields[1] as String?,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      notes: fields[5] as String?,
      isCompleted: fields[6] as bool,
      exerciseSets: (fields[7] as Map).map((dynamic k, dynamic v) =>
        MapEntry(k as String, (v as List).cast<ExerciseSet>())),
    );
  }

  @override
  void write(BinaryWriter writer, ActiveWorkout obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.splitId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.exerciseSets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
