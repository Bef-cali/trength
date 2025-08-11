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
        ? Colors.orangeAccent.withOpacity(0.1)
        : AppColors.velvetPale.withOpacity(0.1);
    final borderColor = isDeload
        ? Colors.orangeAccent.withOpacity(0.3)
        : AppColors.velvetPale.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDeload ? Icons.arrow_downward : Icons.trending_up,
                color: chipColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isDeload ? 'Deload Suggested:' : 'Suggested:',
                style: TextStyle(
                  color: chipColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$weight $weightUnit × $reps reps',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
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
                      color: chipColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: chipColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Apply',
                          style: TextStyle(
                            color: chipColor,
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
          if (strategy != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                strategy,
                style: TextStyle(
                  color: chipColor.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
