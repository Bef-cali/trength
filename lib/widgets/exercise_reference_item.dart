// lib/widgets/exercise_reference_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../models/exercise_reference.dart';
import '../models/exercise_model.dart';
import '../theme/app_colors.dart';

class ExerciseReferenceItem extends StatelessWidget {
  final ExerciseReference exerciseReference;
  final Exercise? exercise;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExerciseReferenceItem({
    Key? key,
    required this.exerciseReference,
    required this.exercise,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle case where exercise might be null (deleted from database)
    final exerciseName = exercise?.name ?? 'Unknown Exercise';
    final categoryName = exercise?.category ?? 'Uncategorized';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.royalVelvet,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.velvetHighlight.withOpacity(0.3),
        highlightColor: AppColors.velvetHighlight.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise order indicator with category icon
                  Stack(
                    children: [
                      _buildCategoryIcon(exercise?.category ?? 'Unknown'),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.velvetMist,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.royalVelvet,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${exerciseReference.order + 1}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Exercise details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise name and category
                        Text(
                          exerciseName,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            color: AppColors.velvetPale,
                          ),
                        ),

                        // Target sets and reps if defined
                        if (exerciseReference.targetSets != null ||
                            exerciseReference.targetReps != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.velvetHighlight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTargetText(),
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.velvetPale,
                                ),
                              ),
                            ),
                          ),

                        // Notes if any
                        if (exerciseReference.notes != null &&
                            exerciseReference.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              exerciseReference.notes!,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 13,
                                color: AppColors.velvetLight.withOpacity(0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // Primary muscles if exercise exists
                        if (exercise != null && exercise!.primaryMuscles.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: exercise!.primaryMuscles.map((muscle) =>
                                _buildChip(muscle)
                              ).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Actions
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.velvetLight,
                          size: 20,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: AppColors.velvetLight,
                          size: 20,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),

              // Reorder handle indicator
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.velvetLight.withOpacity(0.3),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    String iconPath;

    // Assign icon path based on category
    switch (category.toLowerCase()) {
      case 'chest':
        iconPath = 'assets/icons/chest.png';
        break;
      case 'back':
        iconPath = 'assets/icons/back.png';
        break;
      case 'legs':
        iconPath = 'assets/icons/legs.png';
        break;
      case 'shoulders':
        iconPath = 'assets/icons/shoulders.png';
        break;
      case 'arms':
        iconPath = 'assets/icons/arms.png';
        break;
      case 'biceps':
        iconPath = 'assets/icons/arms.png';
        break;
      case 'triceps':
        iconPath = 'assets/icons/triceps.png';
        break;
      case 'forearms':
        iconPath = 'assets/icons/forearms.png';
        break;
      case 'neck':
        iconPath = 'assets/icons/neck.png';
        break;
      case 'core':
      case 'abs':
      case 'abdominals':
        iconPath = 'assets/icons/abs.png';
        break;
      case 'cardio':
        iconPath = 'assets/icons/cardio.png';
        break;
      default:
        iconPath = 'assets/icons/dumbbell.png';
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.velvetHighlight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(
          iconPath,
          width: 30,
          height: 30,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to an icon if image loading fails
            return Icon(
              MaterialCommunityIcons.dumbbell,
              color: Colors.white,
              size: 24,
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.velvetPale.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 10,
          color: AppColors.velvetMist,
        ),
      ),
    );
  }

  String _getTargetText() {
    if (exerciseReference.targetSets != null &&
        exerciseReference.targetReps != null) {
      return '${exerciseReference.targetSets} × ${exerciseReference.targetReps}';
    } else if (exerciseReference.targetSets != null) {
      return '${exerciseReference.targetSets} sets';
    } else if (exerciseReference.targetReps != null) {
      return exerciseReference.targetReps!;
    }
    return '';
  }
}
