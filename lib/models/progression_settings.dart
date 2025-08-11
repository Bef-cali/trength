// lib/models/progression_settings.dart
import 'package:hive/hive.dart';

part 'progression_settings.g.dart';

@HiveType(typeId: 8)
class ProgressionSettings extends HiveObject {
  // Weight increment size for kg
  @HiveField(0)
  double weightIncrementKg;

  // The strategy for progression
  // Options: 'weight_first', 'reps_first', 'volume_first'
  @HiveField(1) // Fixed: Changed from 2 to 1 for sequential numbering
  String progressionStrategy;

  // Minimum reps required before increasing weight
  @HiveField(2) // Fixed: Changed from 3 to 2
  int minRepsBeforeWeightIncrease;

  // Number of workouts without progress to detect a plateau
  @HiveField(3) // Fixed: Changed from 4 to 3
  int plateauThreshold;

  // Percentage to deload by when a plateau is detected
  @HiveField(4) // Fixed: Changed from 5 to 4
  double deloadPercentage;

  // Default rest time between sets in seconds
  @HiveField(5) // Fixed: Changed from 6 to 5
  int defaultRestTimeSeconds;

  ProgressionSettings({
    this.weightIncrementKg = 2.5,
    this.progressionStrategy = 'weight_first',
    this.minRepsBeforeWeightIncrease = 8,
    this.plateauThreshold = 3,
    this.deloadPercentage = 0.10,
    this.defaultRestTimeSeconds = 90,
  });

  // Create a copy with updated fields
  ProgressionSettings copyWith({
    double? weightIncrementKg,
    String? progressionStrategy,
    int? minRepsBeforeWeightIncrease,
    int? plateauThreshold,
    double? deloadPercentage,
    int? defaultRestTimeSeconds,
  }) {
    return ProgressionSettings(
      weightIncrementKg: weightIncrementKg ?? this.weightIncrementKg,
      progressionStrategy: progressionStrategy ?? this.progressionStrategy,
      minRepsBeforeWeightIncrease: minRepsBeforeWeightIncrease ?? this.minRepsBeforeWeightIncrease,
      plateauThreshold: plateauThreshold ?? this.plateauThreshold,
      deloadPercentage: deloadPercentage ?? this.deloadPercentage,
      defaultRestTimeSeconds: defaultRestTimeSeconds ?? this.defaultRestTimeSeconds,
    );
  }

  // Convert to a Map for WorkoutProvider
  Map<String, dynamic> toMap() {
    return {
      'weightIncrementKg': weightIncrementKg,
      'weightIncrementLb': weightIncrementKg * 2.20462, // Keep for compatibility but calculate from kg
      'progressionStrategy': progressionStrategy,
      'minRepsBeforeWeightIncrease': minRepsBeforeWeightIncrease,
      'plateauThreshold': plateauThreshold,
      'deloadPercentage': deloadPercentage,
      'defaultRestTimeSeconds': defaultRestTimeSeconds,
    };
  }

  // Strategy name for display
  String get strategyDisplayName {
    switch (progressionStrategy) {
      case 'weight_first':
        return 'Weight First';
      case 'reps_first':
        return 'Reps First';
      case 'volume_first':
        return 'Volume First';
      default:
        return 'Custom';
    }
  }

  // Description of the selected strategy
  String get strategyDescription {
    switch (progressionStrategy) {
      case 'weight_first':
        return 'Increase weight when you reach $minRepsBeforeWeightIncrease reps, then work back up';
      case 'reps_first':
        return 'Focus on increasing reps to 12 before adding weight';
      case 'volume_first':
        return 'Alternate between increasing reps and weight to maximize volume';
      default:
        return 'Custom progression strategy';
    }
  }
}
