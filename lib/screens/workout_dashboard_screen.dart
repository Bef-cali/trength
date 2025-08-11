// lib/screens/workout_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/split_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_module.dart';
import '../theme/app_colors.dart';
import 'workout_start_screen.dart';
import 'active_workout_screen.dart';
import 'exercise_browse_screen.dart';
import 'progression_settings_screen.dart';

class WorkoutDashboardScreen extends StatelessWidget {
  const WorkoutDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: const Text(
          'TRENGTH',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: AppColors.deepVelvet,
        elevation: 0,
        actions: [
          // Exercise Database quick access
          IconButton(
            icon: const Icon(Icons.fitness_center),
            tooltip: 'Exercise Database',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExerciseBrowseScreen()),
              );
            },
          ),
          // Settings menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'progression_settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgressionSettingsScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'progression_settings',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.velvetPale),
                    SizedBox(width: 8),
                    Text('Progression Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick action buttons with enhanced functionality
            _buildQuickActionSection(context),

            // Current workout or workout module
            const WorkoutModule(),

            // Stats summary
            _buildStatsSummary(context),

            // Split preview
            _buildSplitPreview(context),

            // Spacer at the bottom
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionSection(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, _) {
        return Consumer<SplitProvider>(
          builder: (context, splitProvider, _) {
            final splits = splitProvider.splits;
            final recentSplits = splits.take(3).toList();
            final currentWorkout = workoutProvider.currentWorkout;
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick action buttons row
                  Row(
                    children: [
                      // Resume workout or start new
                      currentWorkout != null
                          ? _buildQuickActionButton(
                              context,
                              Icons.play_arrow,
                              'Resume Workout',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ActiveWorkoutScreen(),
                                  ),
                                );
                              },
                              isHighlighted: true,
                            )
                          : _buildQuickActionButton(
                              context,
                              Icons.play_circle_fill_outlined,
                              'Start Workout',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WorkoutStartScreen(),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(width: 12),
                      _buildQuickActionButton(
                        context,
                        Icons.history,
                        'History',
                        () {
                          Navigator.pushNamed(context, '/workout-history');
                        },
                      ),
                    ],
                  ),
                  
                  // Recently used splits (if no active workout and splits exist)
                  if (currentWorkout == null && recentSplits.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildRecentSplitsSection(context, recentSplits, workoutProvider),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.velvetHighlight : AppColors.royalVelvet,
            borderRadius: BorderRadius.circular(12),
            border: isHighlighted 
                ? Border.all(color: AppColors.velvetMist.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isHighlighted ? Colors.white : AppColors.velvetMist,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: isHighlighted ? Colors.white : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSplitsSection(BuildContext context, List<dynamic> splits, WorkoutProvider workoutProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.royalVelvet.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Start',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Recent Splits',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                  color: AppColors.velvetPale,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...splits.map((split) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                // Quick start with first session of this split
                if (split.sessions.isNotEmpty) {
                  workoutProvider.startWorkoutFromSplit(split, split.sessions.first).then((_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ActiveWorkoutScreen(),
                      ),
                    );
                  });
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.deepVelvet.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: AppColors.velvetPale,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        split.name,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${split.sessions.length} sessions',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: AppColors.velvetLight.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.play_arrow,
                      color: AppColors.velvetMist,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workouts = workoutProvider.getWorkoutHistory();

    // Calculate some basic stats
    final totalWorkouts = workouts.length;
    int totalExercises = 0;
    int totalSets = 0;

    for (final workout in workouts) {
      totalExercises += workout.exerciseSets.length;
      totalSets += workout.completedSets;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stats Summary',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildStatCard(
                'Total Workouts',
                totalWorkouts.toString(),
                Icons.fitness_center,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Total Exercises',
                totalExercises.toString(),
                Icons.list_alt,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Total Sets',
                totalSets.toString(),
                Icons.repeat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.royalVelvet,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.velvetPale,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitPreview(BuildContext context) {
    return Consumer<SplitProvider>(
      builder: (context, splitProvider, _) {
        final splits = splitProvider.splits;

        if (splits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout Splits',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.royalVelvet,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_view_day,
                        size: 48,
                        color: AppColors.velvetLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No workout splits yet',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a split to organize your workouts',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Split'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.velvetHighlight,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/create-split');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Show a preview of the first few splits
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workout Splits',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: AppColors.velvetPale,
                      ),
                    ),
                    onPressed: () {
                      // Navigate to the splits tab
                      Navigator.pushNamed(context, '/splits');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show only the first 2 splits
              ...splits.take(2).map((split) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.royalVelvet,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        split.name,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (split.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            split.description!,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${split.sessions.length} sessions',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            color: AppColors.velvetPale,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }
}
