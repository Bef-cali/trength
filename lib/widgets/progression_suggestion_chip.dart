// lib/widgets/progression_suggestion_chip.dart
import 'package:flutter/material.dart';
import '../models/exercise_set.dart';
import '../theme/app_colors.dart';

class ProgressionSuggestionChip extends StatelessWidget {
  final String exerciseId;
  final Map<String, dynamic> suggestion;
  final bool isDeload;
  final Function(ExerciseSet) onApply;

  const ProgressionSuggestionChip({
    Key? key,
    required this.exerciseId,
    required this.suggestion,
    this.isDeload = false,
    required this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (suggestion.isEmpty) {
      return const SizedBox.shrink();
    }

    // Extract suggestion data
    final weight = suggestion['weight'] as double;
    final weightUnit = suggestion['weightUnit'] as String? ?? 'kg';
    final reps = suggestion['reps'] as int;
    final rpe = suggestion['rpe'] as double?;
    final strategy = suggestion['strategy'] as String?;

    // Colors based on if it's a deload or progression
    final chipColor = isDeload ? Colors.orangeAccent : AppColors.velvetPale;
    final bgColor = isDeload
        ? Colors.orangeAccent.withOpacity(0.08)
        : AppColors.velvetPale.withOpacity(0.08);
    final borderColor = isDeload
        ? Colors.orangeAccent.withOpacity(0.2)
        : AppColors.velvetPale.withOpacity(0.2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced spacing
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Icon and label - more compact
          Icon(
            isDeload ? Icons.trending_down : Icons.trending_up,
            color: chipColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          
          // Suggestion values
          Expanded(
            child: Text(
              '${isDeload ? 'Deload' : 'Next'}: $weight $weightUnit × $reps reps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Strategy hint (very compact)
          if (strategy != null && strategy.length < 20) ...[
            Text(
              '• ${strategy.split(' ').take(2).join(' ')}', // Show first 2 words
              style: TextStyle(
                color: chipColor.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Apply button - more compact
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final newSet = ExerciseSet(
                  weight: weight,
                  weightUnit: weightUnit,
                  reps: reps,
                  rpe: rpe,
                );
                onApply(newSet);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: chipColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Apply',
                      style: TextStyle(
                        color: chipColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New widget for even more compact suggestion display
class CompactSuggestionButton extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final bool isDeload;
  final Function(ExerciseSet) onApply;

  const CompactSuggestionButton({
    Key? key,
    required this.suggestion,
    this.isDeload = false,
    required this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (suggestion.isEmpty) return const SizedBox.shrink();

    final weight = suggestion['weight'] as double;
    final weightUnit = suggestion['weightUnit'] as String? ?? 'kg';
    final reps = suggestion['reps'] as int;
    final rpe = suggestion['rpe'] as double?;

    final chipColor = isDeload ? Colors.orangeAccent : AppColors.velvetPale;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            final newSet = ExerciseSet(
              weight: weight,
              weightUnit: weightUnit,
              reps: reps,
              rpe: rpe,
            );
            onApply(newSet);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: chipColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDeload ? Icons.trending_down : Icons.trending_up,
                  color: chipColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '$weight$weightUnit × $reps',
                  style: TextStyle(
                    color: chipColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.add_circle_outline, color: chipColor, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}