// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 3;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return WorkoutSession(
      id: fields[0] as String,
      name: fields[1] as String,
      sequence: fields[2] as int,
      exercises: (fields[3] as List?)?.cast<ExerciseReference>(),
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.sequence);
    writer.writeByte(3);
    writer.write(obj.exercises);
    writer.writeByte(4);
    writer.write(obj.notes);
  }
}
