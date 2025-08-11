// lib/widgets/session_list_item.dart
import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../theme/app_colors.dart';
import '../screens/split_detail_screen.dart'; // For ReorderDirection enum

class SessionListItem extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(ReorderDirection)? onReorder;

  const SessionListItem({
    Key? key,
    required this.session,
    required this.onTap,
    required this.onDelete,
    this.onReorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  // Fixed: Wrapped in Expanded to provide width constraint
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.velvetPale,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${session.sequence + 1}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            session.name,
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
                      ],
                    ),
                  ),

                  // Actions row - fixed: Ensure this has a defined width by using intrinsic width
                  IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Added this to ensure minimum width
                      children: [
                        if (onReorder != null) ...[
                          // Up button
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward,
                              color: AppColors.velvetLight,
                              size: 20,
                            ),
                            onPressed: () => onReorder!(ReorderDirection.up),
                            tooltip: 'Move Up',
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          // Down button
                          IconButton(
                            icon: Icon(
                              Icons.arrow_downward,
                              color: AppColors.velvetLight,
                              size: 20,
                            ),
                            onPressed: () => onReorder!(ReorderDirection.down),
                            tooltip: 'Move Down',
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                        // Delete button
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
                  ),
                ],
              ),

              // Notes if any
              if (session.notes != null && session.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 40),
                  child: Text(
                    session.notes!,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetLight.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Exercise count
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 40),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: AppColors.velvetPale,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.exercises.length == 1
                          ? '1 Exercise'
                          : '${session.exercises.length} Exercises',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: AppColors.velvetPale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
