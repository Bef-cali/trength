// lib/models/personal_record.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../utils/one_rep_max_calculator.dart';

part 'personal_record.g.dart';

@HiveType(typeId: 7)
class PersonalRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String type; // Now always '1rm' for new records

  @HiveField(3)
  final double value; // The calculated 1RM value

  @HiveField(4)
  final double? weight; // Original weight lifted

  @HiveField(5)
  final int? reps; // Original reps performed

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String workoutId;

  @HiveField(8)
  final String? formula; // Which formula was used (epley, brzycki, lombardi)

  @HiveField(9)
  final String? weightUnit; // kg or lbs

  PersonalRecord({
    String? id,
    required this.exerciseId,
    required this.type,
    required this.value,
    this.weight,
    this.reps,
    required this.date,
    required this.workoutId,
    this.formula,
    this.weightUnit,
  }) : id = id ?? const Uuid().v4();

  // Helper to create a 1RM PR from a set performance
  factory PersonalRecord.oneRMPR({
    required String exerciseId,
    required double weight,
    required int reps,
    required String weightUnit,
    required DateTime date,
    required String workoutId,
  }) {
    final oneRMResult = OneRepMaxCalculator.calculate(
      weight: weight,
      reps: reps,
      weightUnit: weightUnit,
    );

    return PersonalRecord(
      exerciseId: exerciseId,
      type: '1rm',
      value: oneRMResult.oneRepMax,
      weight: weight,
      reps: reps,
      date: date,
      workoutId: workoutId,
      formula: oneRMResult.formulaName.toLowerCase(),
      weightUnit: weightUnit,
    );
  }

  // Helper to create a 1RM PR with pre-calculated value (for migrations)
  factory PersonalRecord.fromCalculated1RM({
    required String exerciseId,
    required double oneRM,
    required double originalWeight,
    required int originalReps,
    required String weightUnit,
    required String formula,
    required DateTime date,
    required String workoutId,
  }) {
    return PersonalRecord(
      exerciseId: exerciseId,
      type: '1rm',
      value: oneRM,
      weight: originalWeight,
      reps: originalReps,
      date: date,
      workoutId: workoutId,
      formula: formula,
      weightUnit: weightUnit,
    );
  }

  // Legacy factory constructors for backward compatibility
  @deprecated
  factory PersonalRecord.weightPR({
    required String exerciseId,
    required double weight,
    required int reps,
    required DateTime date,
    required String workoutId,
  }) {
    return PersonalRecord.oneRMPR(
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
      weightUnit: 'kg', // Default to kg for legacy records
      date: date,
      workoutId: workoutId,
    );
  }

  // Safe getter for reps that defaults to 0 if null
  int get repsOrZero => reps ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'type': type,
      'value': value,
      'weight': weight,
      'reps': reps,
      'date': date.toIso8601String(),
      'workoutId': workoutId,
    };
  }

  String get formattedValue {
    final unit = weightUnit ?? 'kg';
    
    switch (type) {
      case '1rm':
        return 'Est. 1RM: ${value.toStringAsFixed(1)}$unit';
      case 'weight': // Legacy support
        return '$value $unit × $reps';
      case 'reps': // Legacy support
        return '$reps reps at $weight $unit';
      case 'volume': // Legacy support
        return '$value $unit (total volume)';
      default:
        return value.toString();
    }
  }

  String get originalPerformance {
    if (weight != null && reps != null) {
      final unit = weightUnit ?? 'kg';
      return 'from ${weight!.toStringAsFixed(1)}$unit × $reps reps';
    }
    return '';
  }

  String get displayType {
    switch (type) {
      case '1rm':
        return '1RM PR';
      case 'weight': // Legacy support
        return 'Weight PR';
      case 'reps': // Legacy support
        return 'Reps PR';
      case 'volume': // Legacy support
        return 'Volume PR';
      default:
        return 'Personal Record';
    }
  }

  String get formulaUsed {
    if (formula != null) {
      return '${formula!.toUpperCase()} formula';
    }
    return 'Calculated';
  }

  // Helper to get the 1RM value regardless of record type
  double get oneRepMaxValue {
    if (type == '1rm') {
      return value;
    }
    
    // For legacy records, calculate 1RM on the fly
    if (weight != null && reps != null) {
      final result = OneRepMaxCalculator.calculate(
        weight: weight!,
        reps: reps!,
        weightUnit: weightUnit ?? 'kg',
      );
      return result.oneRepMax;
    }
    
    return value; // Fallback to stored value
  }
}
