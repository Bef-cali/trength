import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../models/exercise_model.dart';
import '../theme/app_colors.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback? onAddToWorkout;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.onTap,
    this.onAddToWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      color: AppColors.royalVelvet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise icon based on category
              _buildCategoryIcon(),
              const SizedBox(width: 16),

              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Category
                    Text(
                      exercise.category,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: AppColors.velvetPale,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Primary muscles (using general names)
                    Wrap(
                      spacing: 8,
                      children: exercise.generalPrimaryMuscles.map((muscle) =>
                        _buildChip(muscle, isPrimary: true)
                      ).toList(),
                    ),

                    // Equipment if available
                    if (exercise.equipment != null && exercise.equipment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              MaterialCommunityIcons.dumbbell,
                              size: 14,
                              color: AppColors.velvetLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exercise.equipment!,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 12,
                                color: AppColors.velvetLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.visibility,
                      color: AppColors.velvetMist,
                    ),
                    onPressed: onTap,
                    tooltip: 'View Details',
                  ),
                  if (onAddToWorkout != null)
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.velvetMist,
                      ),
                      onPressed: onAddToWorkout,
                      tooltip: 'Add to Workout',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    String iconPath;

    // Assign icon path based on category
    switch (exercise.category.toLowerCase()) {
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.velvetHighlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(
          iconPath,
          width: 36,
          height: 36,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to an icon if image loading fails
            return Icon(
              MaterialCommunityIcons.dumbbell,
              color: Colors.white,
              size: 28,
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.velvetPale.withOpacity(0.3) : AppColors.velvetHighlight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          color: isPrimary ? AppColors.velvetMist : AppColors.velvetLight,
        ),
      ),
    );
  }
}
