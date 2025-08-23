import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/active_workout.dart';
import '../../theme/app_colors.dart';

class WorkoutTimelineWidget extends StatelessWidget {
  final List<ActiveWorkout> workouts;
  final Function(ActiveWorkout) onWorkoutTap;

  const WorkoutTimelineWidget({
    Key? key,
    required this.workouts,
    required this.onWorkoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.velvetLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No workout history yet',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.velvetLight,
              ),
            ),
          ],
        ),
      );
    }

    // Group workouts by month
    final groupedWorkouts = _groupWorkoutsByMonth(workouts);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedWorkouts.length,
      itemBuilder: (context, index) {
        final monthData = groupedWorkouts[index];
        return MonthTimelineSection(
          monthYear: monthData['monthYear'] as String,
          workouts: monthData['workouts'] as List<ActiveWorkout>,
          onWorkoutTap: onWorkoutTap,
          isLast: index == groupedWorkouts.length - 1,
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupWorkoutsByMonth(List<ActiveWorkout> workouts) {
    // Sort workouts by date (newest first)
    final sortedWorkouts = List<ActiveWorkout>.from(workouts)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final Map<String, List<ActiveWorkout>> grouped = {};

    for (final workout in sortedWorkouts) {
      final monthKey = DateFormat('MMMM yyyy').format(workout.startTime);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(workout);
    }

    // Convert to list and maintain chronological order (newest months first)
    return grouped.entries.map((entry) {
      return {
        'monthYear': entry.key,
        'workouts': entry.value,
      };
    }).toList();
  }
}

class MonthTimelineSection extends StatelessWidget {
  final String monthYear;
  final List<ActiveWorkout> workouts;
  final Function(ActiveWorkout) onWorkoutTap;
  final bool isLast;

  const MonthTimelineSection({
    Key? key,
    required this.monthYear,
    required this.workouts,
    required this.onWorkoutTap,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline for this month (no month header)
        ...workouts.asMap().entries.map((entry) {
          final index = entry.key;
          final workout = entry.value;
          final isLastInMonth = index == workouts.length - 1;
          
          return WorkoutTimelineItem(
            workout: workout,
            onTap: () => onWorkoutTap(workout),
            showConnector: !isLastInMonth || !isLast,
          );
        }).toList(),

        // Add spacing between months (reduced since no header)
        if (!isLast) const SizedBox(height: 24),
      ],
    );
  }
}

class WorkoutTimelineItem extends StatelessWidget {
  final ActiveWorkout workout;
  final VoidCallback onTap;
  final bool showConnector;

  const WorkoutTimelineItem({
    Key? key,
    required this.workout,
    required this.onTap,
    this.showConnector = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(workout.startTime);
    final duration = _formatDuration(workout.duration);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Date
            SizedBox(
              width: 40,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Timeline column
            Column(
              children: [
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.velvetMist,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.velvetMist.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Connector line
                if (showConnector)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.white.withOpacity(0.3),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Right side - Workout info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.velvetPale,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 12,
                          color: AppColors.velvetPale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 14,
                        color: AppColors.velvetPale,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.exerciseSets.length} exercises',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 12,
                          color: AppColors.velvetPale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron icon
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}