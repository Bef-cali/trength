// lib/models/active_workout.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'exercise_set.dart';

part 'active_workout.g.dart';

@HiveType(typeId: 5)
class ActiveWorkout extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? splitId;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  Map<String, List<ExerciseSet>> exerciseSets;

  ActiveWorkout({
    required this.name,
    String? id,
    this.splitId,
    DateTime? startTime,
    this.endTime,
    this.notes,
    this.isCompleted = false,
    Map<String, List<ExerciseSet>>? exerciseSets,
  }) :
    id = id ?? const Uuid().v4(),
    startTime = startTime ?? DateTime.now(),
    exerciseSets = exerciseSets ?? {};

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  int get totalSets {
    int count = 0;
    exerciseSets.forEach((_, sets) => count += sets.length);
    return count;
  }

  int get completedSets {
    int count = 0;
    exerciseSets.forEach((_, sets) {
      count += sets.where((set) => set.completed).length;
    });
    return count;
  }

  double get completionPercentage {
    if (totalSets == 0) return 0.0;
    return (completedSets / totalSets) * 100;
  }

  void addSet(String exerciseId, ExerciseSet set) {
    if (!exerciseSets.containsKey(exerciseId)) {
      exerciseSets[exerciseId] = [];
    }
    exerciseSets[exerciseId]!.add(set);
  }

  void removeSet(String exerciseId, String setId) {
    if (exerciseSets.containsKey(exerciseId)) {
      exerciseSets[exerciseId]!.removeWhere((set) => set.id == setId);
    }
  }

  void completeWorkout() {
    endTime = DateTime.now();
    isCompleted = true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'splitId': splitId,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted,
      'exerciseSets': exerciseSets.map((key, value) => MapEntry(
        key,
        value.map((set) => set.toJson()).toList()
      )),
    };
  }
}
