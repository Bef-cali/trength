// lib/models/exercise_reference.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'exercise_reference.g.dart';

@HiveType(typeId: 4)
class ExerciseReference extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  int order;

  @HiveField(3)
  int? targetSets;

  @HiveField(4)
  String? targetReps;

  @HiveField(5)
  String? notes;

  ExerciseReference({
    String? id,
    required this.exerciseId,
    required this.order,
    this.targetSets,
    this.targetReps,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  // Create a copy with updated fields
  ExerciseReference copyWith({
    int? order,
    int? targetSets,
    String? targetReps,
    String? notes,
  }) {
    return ExerciseReference(
      id: this.id,
      exerciseId: this.exerciseId,
      order: order ?? this.order,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      notes: notes ?? this.notes,
    );
  }
}
