// lib/utils/one_rep_max_calculator.dart
import 'dart:math';

enum OneRMFormula {
  epley,
  brzycki,
  lombardi,
}

class OneRepMaxResult {
  final double oneRepMax;
  final OneRMFormula formula;
  final double originalWeight;
  final int originalReps;
  final String weightUnit;

  OneRepMaxResult({
    required this.oneRepMax,
    required this.formula,
    required this.originalWeight,
    required this.originalReps,
    required this.weightUnit,
  });

  String get formulaName {
    switch (formula) {
      case OneRMFormula.epley:
        return 'Epley';
      case OneRMFormula.brzycki:
        return 'Brzycki';
      case OneRMFormula.lombardi:
        return 'Lombardi';
    }
  }

  String get formattedOneRM {
    return '${oneRepMax.toStringAsFixed(1)}$weightUnit';
  }

  String get originalPerformance {
    return '${originalWeight.toStringAsFixed(1)}$weightUnit × $originalReps reps';
  }
}

class OneRepMaxCalculator {
  // Core formulas

  /// Epley formula - good for 1-10 reps
  /// Formula: weight * (1 + 0.0333 * reps)
  static double epley(double weight, int reps) {
    if (reps <= 0) return weight;
    if (reps == 1) return weight;
    return weight * (1 + 0.0333 * reps);
  }

  /// Brzycki formula - good for 1-12 reps  
  /// Formula: weight * (36 / (37 - reps))
  static double brzycki(double weight, int reps) {
    if (reps <= 0) return weight;
    if (reps == 1) return weight;
    if (reps >= 37) return weight; // Avoid division by zero or negative
    return weight * (36 / (37 - reps));
  }

  /// Lombardi formula - good for 1-5 reps
  /// Formula: weight * Math.pow(reps, 0.10)
  static double lombardi(double weight, int reps) {
    if (reps <= 0) return weight;
    if (reps == 1) return weight;
    return weight * pow(reps, 0.10);
  }

  // Auto-selection logic

  /// Automatically selects the best formula based on rep range
  static OneRMFormula selectBestFormula(int reps) {
    if (reps <= 0) return OneRMFormula.epley;
    
    if (reps >= 1 && reps <= 5) {
      return OneRMFormula.lombardi; // Best for very low reps
    } else if (reps >= 6 && reps <= 10) {
      return OneRMFormula.epley; // Best for moderate reps
    } else if (reps >= 11 && reps <= 12) {
      return OneRMFormula.brzycki; // Best for higher reps
    } else {
      // For 13+ reps, use Epley but results become less reliable
      return OneRMFormula.epley;
    }
  }

  /// Calculate 1RM using the automatically selected best formula
  static OneRepMaxResult calculate({
    required double weight,
    required int reps,
    required String weightUnit,
  }) {
    // Handle edge cases
    if (weight <= 0 || reps <= 0) {
      return OneRepMaxResult(
        oneRepMax: weight,
        formula: OneRMFormula.epley,
        originalWeight: weight,
        originalReps: reps,
        weightUnit: weightUnit,
      );
    }

    // If already 1 rep, return the weight
    if (reps == 1) {
      return OneRepMaxResult(
        oneRepMax: weight,
        formula: OneRMFormula.epley,
        originalWeight: weight,
        originalReps: reps,
        weightUnit: weightUnit,
      );
    }

    final formula = selectBestFormula(reps);
    double oneRM;

    switch (formula) {
      case OneRMFormula.epley:
        oneRM = epley(weight, reps);
        break;
      case OneRMFormula.brzycki:
        oneRM = brzycki(weight, reps);
        break;
      case OneRMFormula.lombardi:
        oneRM = lombardi(weight, reps);
        break;
    }

    return OneRepMaxResult(
      oneRepMax: oneRM,
      formula: formula,
      originalWeight: weight,
      originalReps: reps,
      weightUnit: weightUnit,
    );
  }

  /// Calculate 1RM using a specific formula (for testing/comparison)
  static OneRepMaxResult calculateWithFormula({
    required double weight,
    required int reps,
    required String weightUnit,
    required OneRMFormula formula,
  }) {
    double oneRM;

    switch (formula) {
      case OneRMFormula.epley:
        oneRM = epley(weight, reps);
        break;
      case OneRMFormula.brzycki:
        oneRM = brzycki(weight, reps);
        break;
      case OneRMFormula.lombardi:
        oneRM = lombardi(weight, reps);
        break;
    }

    return OneRepMaxResult(
      oneRepMax: oneRM,
      formula: formula,
      originalWeight: weight,
      originalReps: reps,
      weightUnit: weightUnit,
    );
  }

  /// Helper method to check if a rep count is in a reliable range for 1RM calculation
  static bool isReliableRepRange(int reps) {
    return reps >= 1 && reps <= 12; // Most reliable range for all formulas
  }

  /// Get reliability rating for a given rep count
  static String getReliabilityRating(int reps) {
    if (reps == 1) return 'Exact';
    if (reps >= 2 && reps <= 5) return 'Very High';
    if (reps >= 6 && reps <= 10) return 'High';
    if (reps >= 11 && reps <= 12) return 'Good';
    if (reps >= 13 && reps <= 15) return 'Fair';
    return 'Low'; // 16+ reps
  }
}