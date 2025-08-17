// lib/providers/split_provider.dart
import 'package:flutter/foundation.dart';
import '../models/workout_split.dart';
import '../models/exercise_reference.dart';
import '../repositories/split_repository.dart';

class SplitProvider with ChangeNotifier {
  final SplitRepository _repository;
  List<WorkoutSplit> _splits = [];
  WorkoutSplit? _currentSplit;

  SplitProvider(this._repository) {
    _loadSplits();
  }

  // Getters
  List<WorkoutSplit> get splits => _splits;
  WorkoutSplit? get currentSplit => _currentSplit;
  bool get hasSplits => _splits.isNotEmpty;

  // Load all splits from storage
  Future<void> _loadSplits() async {
    try {
      _splits = await _repository.getAllSplits();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading splits: $e');
      _splits = [];
    }
  }

  // Create a new split
  Future<WorkoutSplit> createSplit({
    required String name,
    String? description,
  }) async {
    final split = WorkoutSplit(
      name: name,
      description: description,
    );

    await _repository.saveSplit(split);
    _splits.add(split);
    _currentSplit = split;
    notifyListeners();
    return split;
  }

  // Update an existing split
  Future<void> updateSplit(WorkoutSplit split) async {
    try {
      final updatedSplit = split.copyWith(
        name: split.name,
        description: split.description,
        exercises: split.exercises,
      );

      await _repository.saveSplit(updatedSplit);

      final index = _splits.indexWhere((s) => s.id == split.id);
      if (index != -1) {
        _splits[index] = updatedSplit;
        if (_currentSplit?.id == split.id) {
          _currentSplit = updatedSplit;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating split: $e');
      rethrow;
    }
  }

  // Delete a split
  Future<void> deleteSplit(String splitId) async {
    try {
      await _repository.deleteSplit(splitId);
      _splits.removeWhere((split) => split.id == splitId);

      if (_currentSplit?.id == splitId) {
        _currentSplit = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting split: $e');
      rethrow;
    }
  }

  // Duplicate a split
  Future<WorkoutSplit> duplicateSplit(String splitId) async {
    try {
      final original = _splits.firstWhere((split) => split.id == splitId);

      // Create new exercise references with new IDs but same content
      final duplicatedExercises = original.exercises.map((exercise) {
        return ExerciseReference(
          exerciseId: exercise.exerciseId,
          order: exercise.order,
          targetSets: exercise.targetSets,
          targetReps: exercise.targetReps,
          notes: exercise.notes,
        );
      }).toList();

      // Create the duplicate split
      final duplicate = WorkoutSplit(
        name: "${original.name} (Copy)",
        description: original.description,
        exercises: duplicatedExercises,
      );

      await _repository.saveSplit(duplicate);
      _splits.add(duplicate);
      notifyListeners();
      return duplicate;
    } catch (e) {
      debugPrint('Error duplicating split: $e');
      rethrow;
    }
  }

  // Set current split
  void setCurrentSplit(String splitId) {
    _currentSplit = _splits.firstWhere(
      (split) => split.id == splitId,
      orElse: () => _currentSplit!,
    );
    notifyListeners();
  }

  // Add an exercise to a split
  Future<void> addExerciseToSplit(
    String splitId,
    String exerciseId,
    {int? targetSets, String? targetReps, String? notes}
  ) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final exerciseCount = split.exercises.length;

      final exerciseRef = ExerciseReference(
        exerciseId: exerciseId,
        order: exerciseCount,
        targetSets: targetSets,
        targetReps: targetReps,
        notes: notes,
      );

      final updatedExercises = List<ExerciseReference>.from(split.exercises)
        ..add(exerciseRef);

      final updatedSplit = split.copyWith(exercises: updatedExercises);
      await updateSplit(updatedSplit);
    } catch (e) {
      debugPrint('Error adding exercise to split: $e');
      rethrow;
    }
  }

  // Remove an exercise from a split
  Future<void> removeExerciseFromSplit(String splitId, String exerciseId) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final updatedExercises = List<ExerciseReference>.from(split.exercises)
        ..removeWhere((exercise) => exercise.exerciseId == exerciseId);

      // Reorder exercises
      for (int i = 0; i < updatedExercises.length; i++) {
        updatedExercises[i] = updatedExercises[i].copyWith(order: i);
      }

      final updatedSplit = split.copyWith(exercises: updatedExercises);
      await updateSplit(updatedSplit);
    } catch (e) {
      debugPrint('Error removing exercise from split: $e');
      rethrow;
    }
  }

  // Reorder exercises within a split
  Future<void> reorderExercisesInSplit(String splitId, int oldIndex, int newIndex) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final updatedExercises = List<ExerciseReference>.from(split.exercises);

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final exercise = updatedExercises.removeAt(oldIndex);
      updatedExercises.insert(newIndex, exercise);

      // Update all order values
      for (int i = 0; i < updatedExercises.length; i++) {
        updatedExercises[i] = updatedExercises[i].copyWith(order: i);
      }

      final updatedSplit = split.copyWith(exercises: updatedExercises);
      await updateSplit(updatedSplit);
    } catch (e) {
      debugPrint('Error reordering exercises in split: $e');
      rethrow;
    }
  }

  // Update exercise in split
  Future<void> updateExerciseInSplit(
    String splitId,
    String exerciseId,
    {int? targetSets, String? targetReps, String? notes}
  ) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final exerciseIndex = split.exercises.indexWhere((e) => e.exerciseId == exerciseId);

      if (exerciseIndex != -1) {
        final updatedExercises = List<ExerciseReference>.from(split.exercises);
        updatedExercises[exerciseIndex] = updatedExercises[exerciseIndex].copyWith(
          targetSets: targetSets,
          targetReps: targetReps,
          notes: notes,
        );

        final updatedSplit = split.copyWith(exercises: updatedExercises);
        await updateSplit(updatedSplit);
      }
    } catch (e) {
      debugPrint('Error updating exercise in split: $e');
      rethrow;
    }
  }

  // Get split by ID
  WorkoutSplit? getSplitById(String splitId) {
    try {
      return _splits.firstWhere((split) => split.id == splitId);
    } catch (e) {
      return null;
    }
  }

  // Refresh splits from storage
  Future<void> refreshSplits() async {
    await _loadSplits();
  }
}