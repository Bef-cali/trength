// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalRecordAdapter extends TypeAdapter<PersonalRecord> {
  @override
  final int typeId = 7;

  @override
  PersonalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalRecord(
      id: fields[0] as String?,
      exerciseId: fields[1] as String,
      type: fields[2] as String,
      value: fields[3] as double,
      weight: fields[4] as double?,
      reps: fields[5] as int?,
      date: fields[6] as DateTime,
      workoutId: fields[7] as String,
      formula: fields[8] as String?,
      weightUnit: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.workoutId)
      ..writeByte(8)
      ..write(obj.formula)
      ..writeByte(9)
      ..write(obj.weightUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
