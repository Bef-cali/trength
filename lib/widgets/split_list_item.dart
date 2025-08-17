// lib/widgets/split_list_item.dart
import 'package:flutter/material.dart';
import '../models/workout_split.dart';
import '../theme/app_colors.dart';

class SplitListItem extends StatelessWidget {
  final WorkoutSplit split;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const SplitListItem({
    Key? key,
    required this.split,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.royalVelvet,
      child: InkWell(
        onTap: onTap,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      split.name,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Actions
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: AppColors.velvetLight,
                          size: 20,
                        ),
                        onPressed: onDuplicate,
                        tooltip: 'Duplicate',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
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

              // Description if any
              if (split.description != null && split.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(
                    split.description!,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetLight.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Sessions summary
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: AppColors.velvetPale,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    split.exercises.length == 1
                        ? '1 Exercise'
                        : '${split.exercises.length} Exercises',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetPale,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Total exercises count
                  Icon(
                    Icons.list,
                    size: 16,
                    color: AppColors.velvetPale,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTotalExercisesText(split),
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetPale,
                    ),
                  ),
                ],
              ),

              // Exercise summary (if needed)
              if (split.exercises.isNotEmpty && split.description?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    split.description!,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 12,
                      color: AppColors.velvetPale.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTotalExercisesText(WorkoutSplit split) {
    final totalExercises = split.exercises.length;

    return totalExercises == 1
        ? '1 Exercise'
        : '$totalExercises Exercises';
  }
}
