// lib/models/exercise_set.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'exercise_set.g.dart';

@HiveType(typeId: 6)
class ExerciseSet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double weight;

  @HiveField(2)
  String weightUnit;

  @HiveField(3)
  int reps;

  @HiveField(4)
  double? rpe;

  @HiveField(5)
  bool isWarmup;

  @HiveField(6)
  bool isDropSet;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool completed;

  @HiveField(9)
  DateTime timestamp;

  ExerciseSet({
    String? id,
    required this.weight,
    this.weightUnit = 'kg',
    required this.reps,
    this.rpe,
    this.isWarmup = false,
    this.isDropSet = false,
    this.notes,
    this.completed = false,
    DateTime? timestamp,
  }) :
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  ExerciseSet copyWith({
    String? id,
    double? weight,
    String? weightUnit,
    int? reps,
    double? rpe,
    bool? isWarmup,
    bool? isDropSet,
    String? notes,
    bool? completed,
    DateTime? timestamp,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      isDropSet: isDropSet ?? this.isDropSet,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'weightUnit': weightUnit,
      'reps': reps,
      'rpe': rpe,
      'isWarmup': isWarmup,
      'isDropSet': isDropSet,
      'notes': notes,
      'completed': completed,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
