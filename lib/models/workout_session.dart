// lib/models/workout_session.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'exercise_reference.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 3)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int sequence;

  @HiveField(3)
  List<ExerciseReference> exercises;

  @HiveField(4)
  String? notes;

  WorkoutSession({
    String? id,
    required this.name,
    required this.sequence,
    List<ExerciseReference>? exercises,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        exercises = exercises ?? [];

  // Create a copy with updated fields
  WorkoutSession copyWith({
    String? name,
    int? sequence,
    List<ExerciseReference>? exercises,
    String? notes,
  }) {
    return WorkoutSession(
      id: this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      exercises: exercises ?? List.from(this.exercises),
      notes: notes ?? this.notes,
    );
  }
}
