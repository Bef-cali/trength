// lib/models/personal_record.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'personal_record.g.dart';

@HiveType(typeId: 7)
class PersonalRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String type; // 'weight', 'reps', 'volume'

  @HiveField(3)
  final double value;

  @HiveField(4)
  final double? weight;

  @HiveField(5)
  final int? reps;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String workoutId;

  PersonalRecord({
    String? id,
    required this.exerciseId,
    required this.type,
    required this.value,
    this.weight,
    this.reps,
    required this.date,
    required this.workoutId,
  }) : id = id ?? const Uuid().v4();

  // Helper to create a weight PR
  factory PersonalRecord.weightPR({
    required String exerciseId,
    required double weight,
    required int reps,
    required DateTime date,
    required String workoutId,
  }) {
    return PersonalRecord(
      exerciseId: exerciseId,
      type: 'weight',
      value: weight,
      weight: weight,
      reps: reps,              // Store original reps
      date: date,
      workoutId: workoutId,
    );
  }

  // Helper to create a reps PR
  factory PersonalRecord.repsPR({
    required String exerciseId,
    required int reps,
    required double weight,
    required DateTime date,
    required String workoutId,
  }) {
    return PersonalRecord(
      exerciseId: exerciseId,
      type: 'reps',
      value: reps.toDouble(),  // Store reps as double in value field
      weight: weight,
      reps: reps,              // Also store original reps as int
      date: date,
      workoutId: workoutId,
    );
  }

  // Helper to create a volume PR
  factory PersonalRecord.volumePR({
    required String exerciseId,
    required double volume,
    required double weight,
    required int reps,
    required DateTime date,
    required String workoutId,
  }) {
    return PersonalRecord(
      exerciseId: exerciseId,
      type: 'volume',
      value: volume,
      weight: weight,
      reps: reps,
      date: date,
      workoutId: workoutId,
    );
  }

  // Safe getter for reps that defaults to 0 if null
  int get repsOrZero => reps ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'type': type,
      'value': value,
      'weight': weight,
      'reps': reps,
      'date': date.toIso8601String(),
      'workoutId': workoutId,
    };
  }

  String get formattedValue {
    switch (type) {
      case 'weight':
        return '$value kg × $reps';
      case 'reps':
        return '$reps reps at $weight kg';
      case 'volume':
        return '$value kg (total volume)';
      default:
        return value.toString();
    }
  }

  String get displayType {
    switch (type) {
      case 'weight':
        return 'Weight PR';
      case 'reps':
        return 'Reps PR';
      case 'volume':
        return 'Volume PR';
      default:
        return type;
    }
  }
}
