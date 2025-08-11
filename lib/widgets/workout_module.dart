// lib/widgets/workout_module.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/exercise_provider.dart';
import '../theme/app_colors.dart';
import '../screens/workout_start_screen.dart';
import '../screens/active_workout_screen.dart';
import '../screens/workout_history_screen.dart';

class WorkoutModule extends StatelessWidget {
  const WorkoutModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, _) {
        final currentWorkout = workoutProvider.currentWorkout;

        // If there's an active workout, show a card to resume it
        if (currentWorkout != null) {
          return _buildActiveWorkoutCard(context, currentWorkout);
        }

        // Otherwise show standard workout actions
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section heading
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workouts',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'History',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: AppColors.velvetPale,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkoutHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Start workout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fitness_center),
                label: const Text('Start Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.velvetHighlight,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutStartScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Recent workout history preview
            _buildRecentWorkouts(context),
          ],
        );
      },
    );
  }

  Widget _buildActiveWorkoutCard(BuildContext context, dynamic currentWorkout) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    // Calculate progress percentage
    final completionPercentage = currentWorkout.completionPercentage;

    // Get exercise count
    final exerciseCount = currentWorkout.exerciseSets.length;

    // Get elapsed time
    final duration = currentWorkout.duration;
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final timeText = hours > 0
        ? '$hours hr ${minutes.toString().padLeft(2, '0')} min'
        : '$minutes min';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppColors.velvetHighlight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.velvetPale.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Active Workout',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              currentWorkout.name,
                              style: const TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${currentWorkout.completedSets}/${currentWorkout.totalSets} sets completed',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${completionPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionPercentage / 100,
                          backgroundColor: AppColors.royalVelvet,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.velvetMist),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats with enhanced information
                  Row(
                    children: [
                      _buildStatBox(
                        'Exercises',
                        exerciseCount.toString(),
                        Icons.fitness_center,
                      ),
                      const SizedBox(width: 16),
                      _buildStatBox(
                        'Duration',
                        timeText,
                        Icons.timer,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rest timer status (if active)
                  Consumer<WorkoutProvider>(
                    builder: (context, workoutProvider, _) {
                      if (workoutProvider.isRestTimerActive || workoutProvider.restTimerSeconds > 0) {
                        final minutes = workoutProvider.restTimerSeconds ~/ 60;
                        final seconds = workoutProvider.restTimerSeconds % 60;
                        final timeRemaining = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                        
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.royalVelvet.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: workoutProvider.isRestTimerActive 
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  workoutProvider.isRestTimerActive ? Icons.timer : Icons.check_circle,
                                  color: workoutProvider.isRestTimerActive ? Colors.orange : Colors.green,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                workoutProvider.isRestTimerActive 
                                    ? 'Rest Timer: $timeRemaining'
                                    : 'Rest Complete',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 12,
                                  color: workoutProvider.isRestTimerActive ? Colors.orange : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            // Resume button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActiveWorkoutScreen(),
                  ),
                );
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.velvetPale,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Resume Workout',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.royalVelvet.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.velvetMist,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, _) {
        final workouts = workoutProvider.getWorkoutHistory();

        if (workouts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: AppColors.velvetLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No workout history yet',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show the 3 most recent workouts
        final recentWorkouts = workouts.take(3).toList();

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: recentWorkouts.length,
          itemBuilder: (context, index) {
            final workout = recentWorkouts[index];
            return _buildRecentWorkoutItem(context, workout);
          },
        );
      },
    );
  }

  Widget _buildRecentWorkoutItem(BuildContext context, dynamic workout) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    // Format date
    final date = '${workout.startTime.day}/${workout.startTime.month}/${workout.startTime.year}';

    // Get exercise count
    final exerciseCount = workout.exerciseSets.length;

    // Get duration
    final duration = workout.duration;
    final minutes = duration.inMinutes;
    final timeText = minutes > 0 ? '$minutes min' : '${duration.inSeconds} sec';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: AppColors.royalVelvet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkoutHistoryScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Date container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.velvetHighlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Workout details
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            '$exerciseCount exercises',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 12,
                              color: AppColors.velvetPale,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white30,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeText,
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

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.velvetLight,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
