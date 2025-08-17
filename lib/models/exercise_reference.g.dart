// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_reference.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseReferenceAdapter extends TypeAdapter<ExerciseReference> {
  @override
  final int typeId = 4;

  @override
  ExerciseReference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseReference(
      id: fields[0] as String?,
      exerciseId: fields[1] as String,
      order: fields[2] as int,
      targetSets: fields[3] as int?,
      targetReps: fields[4] as String?,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseReference obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.order)
      ..writeByte(3)
      ..write(obj.targetSets)
      ..writeByte(4)
      ..write(obj.targetReps)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseReferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
