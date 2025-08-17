// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_split.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSplitAdapter extends TypeAdapter<WorkoutSplit> {
  @override
  final int typeId = 2;

  @override
  WorkoutSplit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSplit(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
      exercises: (fields[5] as List?)?.cast<ExerciseReference>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSplit obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSplitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
