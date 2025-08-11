// lib/providers/split_provider.dart
import 'package:flutter/foundation.dart';
import '../models/workout_split.dart';
import '../models/workout_session.dart';
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
        sessions: split.sessions,
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

      // Create new sessions with new IDs but same content
      final duplicatedSessions = original.sessions.map((session) {
        // Create new exercise references with new IDs
        final duplicatedExercises = session.exercises.map((exercise) {
          return ExerciseReference(
            exerciseId: exercise.exerciseId,
            order: exercise.order,
            targetSets: exercise.targetSets,
            targetReps: exercise.targetReps,
            notes: exercise.notes,
          );
        }).toList();

        return WorkoutSession(
          name: session.name,
          sequence: session.sequence,
          exercises: duplicatedExercises,
          notes: session.notes,
        );
      }).toList();

      // Create the duplicate split
      final duplicate = WorkoutSplit(
        name: "${original.name} (Copy)",
        description: original.description,
        sessions: duplicatedSessions,
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

  // Add a session to a split
  Future<void> addSession(String splitId, WorkoutSession session) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final updatedSessions = List<WorkoutSession>.from(split.sessions)..add(session);

      final updatedSplit = split.copyWith(sessions: updatedSessions);
      await updateSplit(updatedSplit);
    } catch (e) {
      debugPrint('Error adding session: $e');
      rethrow;
    }
  }

  // Update a session in a split
  Future<void> updateSession(String splitId, WorkoutSession session) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final sessionIndex = split.sessions.indexWhere((s) => s.id == session.id);

      if (sessionIndex != -1) {
        final updatedSessions = List<WorkoutSession>.from(split.sessions);
        updatedSessions[sessionIndex] = session;

        final updatedSplit = split.copyWith(sessions: updatedSessions);
        await updateSplit(updatedSplit);
      }
    } catch (e) {
      debugPrint('Error updating session: $e');
      rethrow;
    }
  }

  // Delete a session from a split
  Future<void> deleteSession(String splitId, String sessionId) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final updatedSessions = List<WorkoutSession>.from(split.sessions)
        ..removeWhere((session) => session.id == sessionId);

      // Reorder sequences
      for (int i = 0; i < updatedSessions.length; i++) {
        updatedSessions[i] = updatedSessions[i].copyWith(sequence: i);
      }

      final updatedSplit = split.copyWith(sessions: updatedSessions);
      await updateSplit(updatedSplit);
    } catch (e) {
      debugPrint('Error deleting session: $e');
      rethrow;
    }
  }

  // Reorder sessions within a split
  Future<void> reorderSessions(String splitId, int oldIndex, int newIndex) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final updatedSessions = List<WorkoutSession>.from(split.sessions);

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final session = updatedSessions.removeAt(oldIndex);
      updatedSessions.insert(newIndex, session);

      // Update all sequences
      for (int i = 0; i < updatedSessions.length; i++) {
        updatedSessions[i] = updatedSessions[i].copyWith(sequence: i);
      }

      final updatedSplit = split.copyWith(sessions: updatedSessions);
      await updateSplit(updatedSplit);
    } catch (e) {
      debugPrint('Error reordering sessions: $e');
      rethrow;
    }
  }

  // Add an exercise to a session
  Future<void> addExerciseToSession(
    String splitId,
    String sessionId,
    String exerciseId,
    {int? targetSets, String? targetReps, String? notes}
  ) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final sessionIndex = split.sessions.indexWhere((s) => s.id == sessionId);

      if (sessionIndex != -1) {
        final session = split.sessions[sessionIndex];
        final exerciseCount = session.exercises.length;

        final exerciseRef = ExerciseReference(
          exerciseId: exerciseId,
          order: exerciseCount,
          targetSets: targetSets,
          targetReps: targetReps,
          notes: notes,
        );

        final updatedExercises = List<ExerciseReference>.from(session.exercises)..add(exerciseRef);
        final updatedSession = session.copyWith(exercises: updatedExercises);

        final updatedSessions = List<WorkoutSession>.from(split.sessions);
        updatedSessions[sessionIndex] = updatedSession;

        final updatedSplit = split.copyWith(sessions: updatedSessions);
        await updateSplit(updatedSplit);
      }
    } catch (e) {
      debugPrint('Error adding exercise to session: $e');
      rethrow;
    }
  }

  // Update an exercise in a session
  Future<void> updateExerciseInSession(
    String splitId,
    String sessionId,
    ExerciseReference exercise,
  ) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final sessionIndex = split.sessions.indexWhere((s) => s.id == sessionId);

      if (sessionIndex != -1) {
        final session = split.sessions[sessionIndex];
        final exerciseIndex = session.exercises.indexWhere((e) => e.id == exercise.id);

        if (exerciseIndex != -1) {
          final updatedExercises = List<ExerciseReference>.from(session.exercises);
          updatedExercises[exerciseIndex] = exercise;

          final updatedSession = session.copyWith(exercises: updatedExercises);
          final updatedSessions = List<WorkoutSession>.from(split.sessions);
          updatedSessions[sessionIndex] = updatedSession;

          final updatedSplit = split.copyWith(sessions: updatedSessions);
          await updateSplit(updatedSplit);
        }
      }
    } catch (e) {
      debugPrint('Error updating exercise in session: $e');
      rethrow;
    }
  }

  // Remove an exercise from a session
  Future<void> removeExerciseFromSession(
    String splitId,
    String sessionId,
    String exerciseRefId,
  ) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final sessionIndex = split.sessions.indexWhere((s) => s.id == sessionId);

      if (sessionIndex != -1) {
        final session = split.sessions[sessionIndex];
        final updatedExercises = List<ExerciseReference>.from(session.exercises)
          ..removeWhere((e) => e.id == exerciseRefId);

        // Reorder exercises
        for (int i = 0; i < updatedExercises.length; i++) {
          updatedExercises[i] = updatedExercises[i].copyWith(order: i);
        }

        final updatedSession = session.copyWith(exercises: updatedExercises);
        final updatedSessions = List<WorkoutSession>.from(split.sessions);
        updatedSessions[sessionIndex] = updatedSession;

        final updatedSplit = split.copyWith(sessions: updatedSessions);
        await updateSplit(updatedSplit);
      }
    } catch (e) {
      debugPrint('Error removing exercise from session: $e');
      rethrow;
    }
  }

  // Reorder exercises within a session
  Future<void> reorderExercisesInSession(
    String splitId,
    String sessionId,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      final split = _splits.firstWhere((split) => split.id == splitId);
      final sessionIndex = split.sessions.indexWhere((s) => s.id == sessionId);

      if (sessionIndex != -1) {
        final session = split.sessions[sessionIndex];
        final updatedExercises = List<ExerciseReference>.from(session.exercises);

        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        final exercise = updatedExercises.removeAt(oldIndex);
        updatedExercises.insert(newIndex, exercise);

        // Update all orders
        for (int i = 0; i < updatedExercises.length; i++) {
          updatedExercises[i] = updatedExercises[i].copyWith(order: i);
        }

        final updatedSession = session.copyWith(exercises: updatedExercises);
        final updatedSessions = List<WorkoutSession>.from(split.sessions);
        updatedSessions[sessionIndex] = updatedSession;

        final updatedSplit = split.copyWith(sessions: updatedSessions);
        await updateSplit(updatedSplit);
      }
    } catch (e) {
      debugPrint('Error reordering exercises in session: $e');
      rethrow;
    }
  }
}
