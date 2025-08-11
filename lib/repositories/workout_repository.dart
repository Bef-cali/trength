// lib/repositories/workout_repository.dart
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/active_workout.dart';
import '../models/exercise_set.dart';
import '../models/personal_record.dart';

class WorkoutRepository {
  static const String _activeWorkoutBoxName = 'active_workouts';
  static const String _workoutHistoryBoxName = 'workout_history';
  static const String _personalRecordsBoxName = 'personal_records';

  late Box<ActiveWorkout> _activeWorkoutBox;
  late Box<ActiveWorkout> _workoutHistoryBox;
  late Box<PersonalRecord> _personalRecordsBox;

  Future<void> initialize() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ActiveWorkoutAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ExerciseSetAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(PersonalRecordAdapter());
    }

    // Open boxes
    _activeWorkoutBox = await Hive.openBox<ActiveWorkout>(_activeWorkoutBoxName);
    _workoutHistoryBox = await Hive.openBox<ActiveWorkout>(_workoutHistoryBoxName);
    _personalRecordsBox = await Hive.openBox<PersonalRecord>(_personalRecordsBoxName);
  }

  // CRUD operations for active workouts

  Future<String> saveActiveWorkout(ActiveWorkout workout) async {
    await _activeWorkoutBox.put(workout.id, workout);
    return workout.id;
  }

  ActiveWorkout? getActiveWorkout(String id) {
    return _activeWorkoutBox.get(id);
  }

  List<ActiveWorkout> getAllActiveWorkouts() {
    return _activeWorkoutBox.values.toList();
  }

  Future<void> deleteActiveWorkout(String id) async {
    await _activeWorkoutBox.delete(id);
  }

  // Workout history operations

  Future<String> addToHistory(ActiveWorkout workout) async {
    // Make sure the workout is marked as completed
    if (!workout.isCompleted) {
      workout.completeWorkout();
    }

    // Remove from active workouts if it exists there
    await _activeWorkoutBox.delete(workout.id);

    // Add to history
    await _workoutHistoryBox.put(workout.id, workout);

    // Check for personal records in this workout
    await _checkAndUpdatePersonalRecords(workout);

    return workout.id;
  }

  List<ActiveWorkout> getWorkoutHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? splitId,
    String? exerciseId,
  }) {
    var workouts = _workoutHistoryBox.values.toList();

    // Apply filters
    if (startDate != null) {
      workouts = workouts.where((w) => w.startTime.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      workouts = workouts.where((w) => w.startTime.isBefore(endDate)).toList();
    }

    if (splitId != null) {
      workouts = workouts.where((w) => w.splitId == splitId).toList();
    }

    if (exerciseId != null) {
      workouts = workouts.where((w) => w.exerciseSets.containsKey(exerciseId)).toList();
    }

    // Sort by date (newest first)
    workouts.sort((a, b) => b.startTime.compareTo(a.startTime));

    return workouts;
  }

  ActiveWorkout? getWorkoutById(String id) {
    return _workoutHistoryBox.get(id);
  }

  Future<void> clearWorkoutHistory() async {
    await _workoutHistoryBox.clear();
  }

  // Get previous performance for an exercise
  List<ExerciseSet> getPreviousSets(String exerciseId, {int limit = 5}) {
    List<ExerciseSet> allSets = [];

    // Get workouts that contain this exercise
    final workouts = _workoutHistoryBox.values
        .where((w) => w.exerciseSets.containsKey(exerciseId))
        .toList();

    // Sort workouts by date (newest first)
    workouts.sort((a, b) => b.startTime.compareTo(a.startTime));

    // Extract sets from the most recent workouts
    for (var workout in workouts) {
      final sets = workout.exerciseSets[exerciseId] ?? [];
      // Skip warmup sets
      final workingSets = sets.where((s) => !s.isWarmup).toList();
      allSets.addAll(workingSets);

      if (allSets.length >= limit) {
        break;
      }
    }

    return allSets.take(limit).toList();
  }

  // Get the best performance for an exercise
  ExerciseSet? getBestSet(String exerciseId, {bool byWeight = true}) {
    final workouts = _workoutHistoryBox.values
        .where((w) => w.exerciseSets.containsKey(exerciseId))
        .toList();

    List<ExerciseSet> allSets = [];
    for (var workout in workouts) {
      final sets = workout.exerciseSets[exerciseId] ?? [];
      // Skip warmup sets
      final workingSets = sets.where((s) => !s.isWarmup).toList();
      allSets.addAll(workingSets);
    }

    if (allSets.isEmpty) {
      return null;
    }

    if (byWeight) {
      // Find the set with the highest weight (for the same unit)
      // If there are multiple sets with the same weight, choose the one with more reps
      return allSets.reduce((a, b) {
        if (a.weightUnit != b.weightUnit) return a; // Can't compare different units
        if (a.weight > b.weight) return a;
        if (a.weight < b.weight) return b;
        return a.reps > b.reps ? a : b;
      });
    } else {
      // Find the set with the highest volume (weight * reps)
      return allSets.reduce((a, b) {
        if (a.weightUnit != b.weightUnit) return a; // Can't compare different units
        final aVolume = a.weight * a.reps;
        final bVolume = b.weight * b.reps;
        return aVolume > bVolume ? a : b;
      });
    }
  }

  // Get performance trend for an exercise (for charts)
  List<Map<String, dynamic>> getPerformanceTrend(String exerciseId, {
    int limit = 10,
    bool byWeight = true,
  }) {
    final workouts = _workoutHistoryBox.values
        .where((w) => w.exerciseSets.containsKey(exerciseId))
        .toList();

    // Sort workouts by date (oldest first for trend analysis)
    workouts.sort((a, b) => a.startTime.compareTo(b.startTime));

    List<Map<String, dynamic>> performanceData = [];

    for (var workout in workouts) {
      // Get the best working set from this workout
      final sets = workout.exerciseSets[exerciseId] ?? [];
      final workingSets = sets.where((s) => !s.isWarmup).toList();

      if (workingSets.isNotEmpty) {
        // Find the best set in this workout
        ExerciseSet bestSet;

        if (byWeight) {
          // Sort by weight (for the same unit), then by reps
          bestSet = workingSets.reduce((a, b) {
            if (a.weightUnit != b.weightUnit) return a; // Can't compare different units
            if (a.weight > b.weight) return a;
            if (a.weight < b.weight) return b;
            return a.reps > b.reps ? a : b;
          });
        } else {
          // Sort by volume (weight * reps)
          bestSet = workingSets.reduce((a, b) {
            if (a.weightUnit != b.weightUnit) return a; // Can't compare different units
            final aVolume = a.weight * a.reps;
            final bVolume = b.weight * b.reps;
            return aVolume > bVolume ? a : b;
          });
        }

        performanceData.add({
          'date': workout.startTime,
          'weight': bestSet.weight,
          'weightUnit': bestSet.weightUnit,
          'reps': bestSet.reps,
          'volume': bestSet.weight * bestSet.reps,
          'rpe': bestSet.rpe,
        });
      }
    }

    // Return the most recent limit entries
    if (performanceData.length > limit) {
      performanceData = performanceData.sublist(performanceData.length - limit);
    }

    return performanceData;
  }

  // Check if a set is a personal record
  bool isPersonalRecord(String exerciseId, ExerciseSet set) {
    final bestSet = getBestSet(exerciseId);
    if (bestSet == null) return true; // First time is always a PR

    // Can't compare different units
    if (bestSet.weightUnit != set.weightUnit) return false;

    // Check if this set has a higher weight with at least the same reps
    if (set.weight > bestSet.weight && set.reps >= bestSet.reps) {
      return true;
    }

    // Check if this set has the same weight but more reps
    if (set.weight == bestSet.weight && set.reps > bestSet.reps) {
      return true;
    }

    // Check if this set has a higher volume
    if (set.weight * set.reps > bestSet.weight * bestSet.reps) {
      return true;
    }

    return false;
  }

  // Get suggested weight/reps for progressive overload
  Map<String, dynamic> getSuggestedProgression(
    String exerciseId,
    {double weightIncrementKg = 2.5,
     double weightIncrementLb = 5.0,
     int minRepsBeforeWeightIncrease = 8,
     String progressionStrategy = 'weight_first' // 'weight_first', 'reps_first', 'volume_first'
    }) {

    // Get the last set data
    final previousSets = getPreviousSets(exerciseId);
    if (previousSets.isEmpty) {
      // No previous data, return empty suggestion
      return {};
    }

    final lastSet = previousSets.first;
    final weightIncrement = lastSet.weightUnit.toLowerCase() == 'kg'
        ? weightIncrementKg
        : weightIncrementLb;

    // Calculate suggestions based on strategy
    switch (progressionStrategy) {
      case 'weight_first':
        // If reached target reps, increase weight
        if (lastSet.reps >= minRepsBeforeWeightIncrease) {
          return {
            'weight': lastSet.weight + weightIncrement,
            'weightUnit': lastSet.weightUnit,
            'reps': max(lastSet.reps - 2, 1), // Drop reps slightly when increasing weight
            'rpe': lastSet.rpe != null ? min(lastSet.rpe! + 0.5, 10.0) : null,
            'strategy': 'Increase weight, decrease reps',
          };
        } else {
          // Otherwise aim for more reps at same weight
          return {
            'weight': lastSet.weight,
            'weightUnit': lastSet.weightUnit,
            'reps': lastSet.reps + 1,
            'rpe': lastSet.rpe,
            'strategy': 'Increase reps',
          };
        }

      case 'reps_first':
        // Always try to increase reps first, then weight when hitting upper rep limit
        if (lastSet.reps >= 12) {
          return {
            'weight': lastSet.weight + weightIncrement,
            'weightUnit': lastSet.weightUnit,
            'reps': 8, // Reset to lower rep range with higher weight
            'rpe': lastSet.rpe,
            'strategy': 'Increase weight, reset reps',
          };
        } else {
          return {
            'weight': lastSet.weight,
            'weightUnit': lastSet.weightUnit,
            'reps': lastSet.reps + 1,
            'rpe': lastSet.rpe,
            'strategy': 'Increase reps',
          };
        }

      case 'volume_first':
        // Try to increase total volume (weight × reps)
        // Alternate between weight and rep increases
        if (lastSet.reps >= 10) {
          return {
            'weight': lastSet.weight + weightIncrement,
            'weightUnit': lastSet.weightUnit,
            'reps': 6, // Reset to lower rep range with higher weight
            'rpe': lastSet.rpe,
            'strategy': 'Increase weight, reset reps',
          };
        } else {
          return {
            'weight': lastSet.weight,
            'weightUnit': lastSet.weightUnit,
            'reps': lastSet.reps + 1,
            'rpe': lastSet.rpe,
            'strategy': 'Increase reps',
          };
        }

      default:
        // Default to weight-first strategy
        if (lastSet.reps >= minRepsBeforeWeightIncrease) {
          return {
            'weight': lastSet.weight + weightIncrement,
            'weightUnit': lastSet.weightUnit,
            'reps': max(lastSet.reps - 2, 1),
            'rpe': lastSet.rpe,
            'strategy': 'Increase weight, decrease reps',
          };
        } else {
          return {
            'weight': lastSet.weight,
            'weightUnit': lastSet.weightUnit,
            'reps': lastSet.reps + 1,
            'rpe': lastSet.rpe,
            'strategy': 'Increase reps',
          };
        }
    }
  }

  // Detect plateau and suggest deload
  Map<String, dynamic> checkForPlateauAndSuggestDeload(
    String exerciseId,
    {int plateauThreshold = 3, // Number of workouts with no progress
     double deloadPercentage = 0.10, // Deload by 10%
    }) {
    final trend = getPerformanceTrend(exerciseId);

    if (trend.length < plateauThreshold + 1) {
      // Not enough data to determine plateau
      return {
        'isPlateaued': false,
        'deloadSuggestion': null,
      };
    }

    // Check last plateauThreshold workouts for progress
    bool isProgressing = false;
    final recentWorkouts = trend.sublist(trend.length - plateauThreshold - 1);

    // Compare first and last workout in the recent set
    final firstWorkout = recentWorkouts.first;
    final lastWorkout = recentWorkouts.last;

    // Check if there's any progress in weight, reps, or volume
    if (lastWorkout['weight'] > firstWorkout['weight'] ||
        lastWorkout['reps'] > firstWorkout['reps'] ||
        lastWorkout['volume'] > firstWorkout['volume']) {
      isProgressing = true;
    }

    if (!isProgressing) {
      // Calculate deload suggestion
      final lastWeight = lastWorkout['weight'];
      final deloadWeight = lastWeight * (1 - deloadPercentage);

      return {
        'isPlateaued': true,
        'weeksWithoutProgress': plateauThreshold,
        'deloadSuggestion': {
          'weight': deloadWeight,
          'weightUnit': lastWorkout['weightUnit'],
          'reps': lastWorkout['reps'] + 2, // Slightly higher reps with lower weight
          'strategy': 'Deload weight, increase reps slightly',
        },
      };
    }

    return {
      'isPlateaued': false,
      'deloadSuggestion': null,
    };
  }

  // Personal Records Management

  Future<void> _checkAndUpdatePersonalRecords(ActiveWorkout workout) async {
    // Iterate through each exercise in the workout
    for (var entry in workout.exerciseSets.entries) {
      final exerciseId = entry.key;
      final sets = entry.value;

      if (sets.isEmpty) continue;

      // Skip warmup sets and only consider completed sets
      final workingSets = sets.where((s) => !s.isWarmup && s.completed).toList();
      if (workingSets.isEmpty) continue;

      // Check for weight PR
      final weightPR = _getPersonalRecord(exerciseId, 'weight');
      final bestSetByWeight = workingSets.reduce((a, b) {
        if (a.weight > b.weight) return a;
        if (a.weight < b.weight) return b;
        // If weights are equal, choose the one with more reps
        return a.reps > b.reps ? a : b;
      });

      // If no PR exists or this set is better, save it
      if (weightPR == null ||
          bestSetByWeight.weight > weightPR.value ||
          (bestSetByWeight.weight == weightPR.value &&
           bestSetByWeight.reps > (weightPR.reps ?? 0))) {
        await _savePersonalRecord(
          exerciseId: exerciseId,
          type: 'weight',
          value: bestSetByWeight.weight,
          reps: bestSetByWeight.reps,
          date: workout.startTime,
          workoutId: workout.id,
        );
      }

      // Check for reps PR
      final repsPR = _getPersonalRecord(exerciseId, 'reps');
      final bestSetByReps = workingSets.reduce((a, b) => a.reps > b.reps ? a : b);

      // If no PR exists or this set has more reps, save it
      if (repsPR == null || bestSetByReps.reps > repsPR.value.toInt()) {
        await _savePersonalRecord(
          exerciseId: exerciseId,
          type: 'reps',
          value: bestSetByReps.reps.toDouble(),
          weight: bestSetByReps.weight,
          date: workout.startTime,
          workoutId: workout.id,
        );
      }

      // Check for volume PR
      final volumePR = _getPersonalRecord(exerciseId, 'volume');
      final bestSetByVolume = workingSets.reduce((a, b) {
        final aVolume = a.weight * a.reps;
        final bVolume = b.weight * b.reps;
        return aVolume > bVolume ? a : b;
      });

      final bestVolume = bestSetByVolume.weight * bestSetByVolume.reps;

      // If no PR exists or this set has more volume, save it
      if (volumePR == null || bestVolume > volumePR.value) {
        await _savePersonalRecord(
          exerciseId: exerciseId,
          type: 'volume',
          value: bestVolume,
          weight: bestSetByVolume.weight,
          reps: bestSetByVolume.reps,
          date: workout.startTime,
          workoutId: workout.id,
        );
      }
    }
  }

  PersonalRecord? _getPersonalRecord(String exerciseId, String type) {
    final key = '$exerciseId-$type';
    return _personalRecordsBox.get(key);
  }

  Future<void> _savePersonalRecord({
    required String exerciseId,
    required String type,
    required double value,
    double? weight,
    int? reps,
    required DateTime date,
    required String workoutId,
  }) async {
    final key = '$exerciseId-$type';
    final pr = PersonalRecord(
      exerciseId: exerciseId,
      type: type,
      value: value,
      weight: weight,
      reps: reps,
      date: date,
      workoutId: workoutId,
    );

    await _personalRecordsBox.put(key, pr);
  }

  List<PersonalRecord> getPersonalRecordsForExercise(String exerciseId) {
    return _personalRecordsBox.values
        .where((pr) => pr.exerciseId == exerciseId)
        .toList();
  }

  // Compare current set with previous best performance
  Map<String, dynamic> compareWithPrevious(String exerciseId, ExerciseSet currentSet) {
    final previousSets = getPreviousSets(exerciseId);
    if (previousSets.isEmpty) {
      return {
        'isFirstTime': true,
        'weightDiff': 0.0,
        'repsDiff': 0,
        'volumeDiff': 0.0,
      };
    }

    final previousSet = previousSets.first;

    // Can only compare with same weight unit
    if (previousSet.weightUnit != currentSet.weightUnit) {
      return {
        'isDifferentUnit': true,
        'weightDiff': 0.0,
        'repsDiff': 0,
        'volumeDiff': 0.0,
      };
    }

    final weightDiff = currentSet.weight - previousSet.weight;
    final repsDiff = currentSet.reps - previousSet.reps;
    final currentVolume = currentSet.weight * currentSet.reps;
    final previousVolume = previousSet.weight * previousSet.reps;
    final volumeDiff = currentVolume - previousVolume;
    final volumePercentChange = previousVolume > 0
        ? (volumeDiff / previousVolume) * 100
        : 0.0;

    return {
      'weightDiff': weightDiff,
      'repsDiff': repsDiff,
      'volumeDiff': volumeDiff,
      'volumePercentChange': volumePercentChange,
      'isPR': isPersonalRecord(exerciseId, currentSet),
    };
  }
}
