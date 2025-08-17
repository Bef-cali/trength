// lib/models/workout_split.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'exercise_reference.dart';

part 'workout_split.g.dart';

@HiveType(typeId: 2)
class WorkoutSplit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  List<ExerciseReference> exercises;

  WorkoutSplit({
    String? id,
    required this.name,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ExerciseReference>? exercises,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        exercises = exercises ?? [];

  // Create a copy with updated fields
  WorkoutSplit copyWith({
    String? name,
    String? description,
    List<ExerciseReference>? exercises,
  }) {
    return WorkoutSplit(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      exercises: exercises ?? List.from(this.exercises),
    );
  }
}
