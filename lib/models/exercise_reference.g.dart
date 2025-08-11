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
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return ExerciseReference(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      order: fields[2] as int,
      targetSets: fields[3] as int?,
      targetReps: fields[4] as String?,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseReference obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.exerciseId);
    writer.writeByte(2);
    writer.write(obj.order);
    writer.writeByte(3);
    writer.write(obj.targetSets);
    writer.writeByte(4);
    writer.write(obj.targetReps);
    writer.writeByte(5);
    writer.write(obj.notes);
  }
}
