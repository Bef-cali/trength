// lib/repositories/split_repository.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_split.dart';
import '../models/exercise_reference.dart';

class SplitRepository {
  static const String _splitBoxName = 'workout_splits';

  Future<void> initialize() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WorkoutSplitAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ExerciseReferenceAdapter());
    }

    // Open the box if not already open
    if (!Hive.isBoxOpen(_splitBoxName)) {
      await Hive.openBox<WorkoutSplit>(_splitBoxName);
    }
  }

  // Get the Hive box
  Future<Box<WorkoutSplit>> _getBox() async {
    if (!Hive.isBoxOpen(_splitBoxName)) {
      await initialize();
    }
    return Hive.box<WorkoutSplit>(_splitBoxName);
  }

  // Get all splits
  Future<List<WorkoutSplit>> getAllSplits() async {
    final box = await _getBox();
    return box.values.toList();
  }

  // Get a split by ID
  Future<WorkoutSplit?> getSplitById(String id) async {
    final box = await _getBox();
    final splits = box.values.where((split) => split.id == id).toList();
    return splits.isNotEmpty ? splits.first : null;
  }

  // Save a split (create or update)
  Future<void> saveSplit(WorkoutSplit split) async {
    final box = await _getBox();
    await box.put(split.id, split);
  }

  // Delete a split
  Future<void> deleteSplit(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  // Get splits containing a specific exercise
  Future<List<WorkoutSplit>> getSplitsContainingExercise(String exerciseId) async {
    final allSplits = await getAllSplits();
    return allSplits.where((split) {
      return split.exercises.any((exercise) => exercise.exerciseId == exerciseId);
    }).toList();
  }
}
