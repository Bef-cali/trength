import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/workout_provider.dart';

class RecentWorkoutStatsWidget extends StatelessWidget {
  const RecentWorkoutStatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final recentWorkout = _getMostRecentWorkout(workoutProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent workout',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.timer_outlined,
                  value: recentWorkout['duration'] ?? '0',
                  label: 'Total Duration',
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  icon: Icons.fitness_center,
                  value: recentWorkout['exercises'] ?? '0',
                  label: 'Total Exercises',
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  icon: Icons.repeat,
                  value: recentWorkout['sets'] ?? '0',
                  label: 'Total Sets',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.royalVelvet,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getMostRecentWorkout(WorkoutProvider workoutProvider) {
    final workouts = workoutProvider.getWorkoutHistory();

    if (workouts.isEmpty) {
      return {
        'duration': '0',
        'exercises': '0',
        'sets': '0',
      };
    }

    // Get the most recent completed workout
    final recentWorkout = workouts.first;

    // Calculate duration
    String duration = '0';
    if (recentWorkout.isCompleted &&
        recentWorkout.endTime != null &&
        recentWorkout.startTime != null) {
      final workoutDuration = recentWorkout.endTime!.difference(recentWorkout.startTime);
      final minutes = workoutDuration.inMinutes;
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        duration = remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
      } else {
        duration = '${minutes}m';
      }
    }

    // Calculate exercises and sets
    int exerciseCount = 0;
    int setCount = 0;

    if (recentWorkout.exerciseSets != null) {
      exerciseCount = recentWorkout.exerciseSets.length;

      recentWorkout.exerciseSets.forEach((exerciseId, sets) {
        if (sets != null) {
          setCount += sets.where((set) => set.completed == true).length;
        }
      });
    }

    return {
      'duration': duration,
      'exercises': exerciseCount.toString(),
      'sets': setCount.toString(),
    };
  }
}
