// lib/utils/progression_calculator.dart
import 'dart:math';
import '../models/exercise_set.dart';
import '../models/progression_settings.dart';

class ProgressionCalculator {
  // Calculate suggested progression based on previous performance
  static Map<String, dynamic> calculateProgression(
    ExerciseSet previousSet,
    ProgressionSettings settings,
  ) {
    // Fixed: Always use kg increment regardless of unit
    // We'll convert if needed
    final weightIncrement = settings.weightIncrementKg;

    // For lb units, convert the kg increment to lb (roughly)
    final adjustedIncrement = previousSet.weightUnit.toLowerCase() == 'kg'
        ? weightIncrement
        : weightIncrement * 2.20462; // Convert kg to lb

    // Calculate suggestions based on strategy
    switch (settings.progressionStrategy) {
      case 'weight_first':
        return _calculateWeightFirstProgression(
          previousSet, adjustedIncrement, settings.minRepsBeforeWeightIncrease);

      case 'reps_first':
        return _calculateRepsFirstProgression(previousSet, adjustedIncrement);

      case 'volume_first':
        return _calculateVolumeFirstProgression(previousSet, adjustedIncrement);

      default:
        // Default to weight-first strategy
        return _calculateWeightFirstProgression(
          previousSet, adjustedIncrement, settings.minRepsBeforeWeightIncrease);
    }
  }

  // Weight-first strategy: increases weight when target reps are reached
  static Map<String, dynamic> _calculateWeightFirstProgression(
    ExerciseSet previousSet,
    double weightIncrement,
    int minRepsBeforeWeightIncrease,
  ) {
    // If reached target reps, increase weight
    if (previousSet.reps >= minRepsBeforeWeightIncrease) {
      return {
        'weight': previousSet.weight + weightIncrement,
        'weightUnit': previousSet.weightUnit,
        'reps': max(previousSet.reps - 2, 1), // Drop reps slightly when increasing weight
        'rpe': previousSet.rpe != null ? min(previousSet.rpe! + 0.5, 10.0) : null,
        'strategy': 'Increase weight, decrease reps',
      };
    } else {
      // Otherwise aim for more reps at same weight
      return {
        'weight': previousSet.weight,
        'weightUnit': previousSet.weightUnit,
        'reps': previousSet.reps + 1,
        'rpe': previousSet.rpe,
        'strategy': 'Increase reps',
      };
    }
  }

  // Reps-first strategy: focuses on building up reps before adding weight
  static Map<String, dynamic> _calculateRepsFirstProgression(
    ExerciseSet previousSet,
    double weightIncrement,
  ) {
    // Always try to increase reps first, then weight when hitting upper rep limit
    if (previousSet.reps >= 12) {
      return {
        'weight': previousSet.weight + weightIncrement,
        'weightUnit': previousSet.weightUnit,
        'reps': 8, // Reset to lower rep range with higher weight
        'rpe': previousSet.rpe,
        'strategy': 'Increase weight, reset reps',
      };
    } else {
      return {
        'weight': previousSet.weight,
        'weightUnit': previousSet.weightUnit,
        'reps': previousSet.reps + 1,
        'rpe': previousSet.rpe,
        'strategy': 'Increase reps',
      };
    }
  }

  // Volume-first strategy: alternates between weight and rep increases
  static Map<String, dynamic> _calculateVolumeFirstProgression(
    ExerciseSet previousSet,
    double weightIncrement,
  ) {
    // Try to increase total volume (weight × reps)
    // Alternate between weight and rep increases
    if (previousSet.reps >= 10) {
      return {
        'weight': previousSet.weight + weightIncrement,
        'weightUnit': previousSet.weightUnit,
        'reps': 6, // Reset to lower rep range with higher weight
        'rpe': previousSet.rpe,
        'strategy': 'Increase weight, reset reps',
      };
    } else {
      return {
        'weight': previousSet.weight,
        'weightUnit': previousSet.weightUnit,
        'reps': previousSet.reps + 1,
        'rpe': previousSet.rpe,
        'strategy': 'Increase reps',
      };
    }
  }

  // Calculate deload suggestion when a plateau is detected
  static Map<String, dynamic> calculateDeload(
    ExerciseSet plateauSet,
    double deloadPercentage,
  ) {
    final deloadWeight = plateauSet.weight * (1 - deloadPercentage);

    return {
      'weight': deloadWeight,
      'weightUnit': plateauSet.weightUnit,
      'reps': plateauSet.reps + 2, // Slightly higher reps with lower weight
      'rpe': plateauSet.rpe != null ? max(plateauSet.rpe! - 1, 6.0) : null,
      'strategy': 'Deload weight, increase reps slightly',
    };
  }

  // Check if a set is a personal record compared to a previous best
  static bool isPersonalRecord(ExerciseSet currentSet, ExerciseSet? previousBest) {
    if (previousBest == null) return true; // First time is always a PR

    // Can't compare different units
    if (previousBest.weightUnit != currentSet.weightUnit) return false;

    // Check if this set has a higher weight with at least the same reps
    if (currentSet.weight > previousBest.weight && currentSet.reps >= previousBest.reps) {
      return true;
    }

    // Check if this set has the same weight but more reps
    if (currentSet.weight == previousBest.weight && currentSet.reps > previousBest.reps) {
      return true;
    }

    // Check if this set has a higher volume
    if (currentSet.weight * currentSet.reps > previousBest.weight * previousBest.reps) {
      return true;
    }

    return false;
  }

  // Calculate the estimated one-rep max (1RM) using the Brzycki formula
  static double calculateOneRepMax(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;

    // Brzycki formula: 1RM = weight × (36 / (37 - reps))
    return weight * (36 / (37 - min(reps, 36)));
  }

  // Calculate the appropriate weight for a target number of reps based on 1RM
  static double calculateWeightForReps(double oneRepMax, int targetReps) {
    if (targetReps <= 0) return 0;
    if (targetReps == 1) return oneRepMax;

    // Reverse Brzycki formula
    return oneRepMax * ((37 - targetReps) / 36);
  }

  // Calculate the total volume of a workout for an exercise
  static double calculateTotalVolume(List<ExerciseSet> sets) {
    double totalVolume = 0;

    for (var set in sets) {
      if (!set.isWarmup && set.completed) {
        totalVolume += set.weight * set.reps;
      }
    }

    return totalVolume;
  }

  // Calculate the best set from a list of sets (based on 1RM)
  static ExerciseSet? findBestSet(List<ExerciseSet> sets) {
    if (sets.isEmpty) return null;

    ExerciseSet? bestSet;
    double bestOneRM = 0;

    for (var set in sets) {
      if (!set.isWarmup && set.completed) {
        final oneRM = calculateOneRepMax(set.weight, set.reps);
        if (oneRM > bestOneRM) {
          bestOneRM = oneRM;
          bestSet = set;
        }
      }
    }

    return bestSet;
  }
}
