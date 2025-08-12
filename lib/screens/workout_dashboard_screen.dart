// lib/screens/workout_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/split_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_module.dart';
import '../theme/app_colors.dart';
import '../models/workout_session.dart';
import '../models/workout_split.dart';
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
            final currentWorkout = workoutProvider.currentWorkout;
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Resume workout button (only if there's an active workout)
                  if (currentWorkout != null)
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
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
                          ),
                        ),
                      ],
                    ),
                  
                  // Recent sessions section (always show if no active workout)
                  if (currentWorkout == null) ...[
                    _buildRecentSessionsSection(context, workoutProvider, splitProvider),
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

  Widget _buildRecentSessionsSection(BuildContext context, WorkoutProvider workoutProvider, SplitProvider splitProvider) {
    // Get recent completed workouts to extract sessions
    final recentWorkouts = workoutProvider.getWorkoutHistory();
    final recentSessions = <Map<String, dynamic>>[];
    
    // Extract unique sessions from recent workouts (last 10 workouts)
    final sessionNames = <String>{};
    for (final workout in recentWorkouts.take(10)) {
      if (workout.splitId != null && !sessionNames.contains(workout.name)) {
        final splitMatches = splitProvider.splits.where((s) => s.id == workout.splitId);
        if (splitMatches.isNotEmpty) {
          final split = splitMatches.first;
          final sessionMatches = split.sessions.where((s) => s.name == workout.name);
          if (sessionMatches.isNotEmpty) {
            final session = sessionMatches.first;
            recentSessions.add({
              'session': session,
              'split': split,
              'lastPerformed': workout.startTime,
            });
            sessionNames.add(workout.name);
          }
        }
      }
    }
    
    // If no recent sessions, show available sessions from splits
    if (recentSessions.isEmpty) {
      for (final split in splitProvider.splits.take(3)) {
        for (final session in split.sessions.take(2)) {
          recentSessions.add({
            'session': session,
            'split': split,
            'lastPerformed': null,
          });
          if (recentSessions.length >= 6) break;
        }
        if (recentSessions.length >= 6) break;
      }
    }
    
    if (recentSessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.royalVelvet.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: AppColors.velvetLight.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No sessions available',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a split with sessions to start working out',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
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
      );
    }
    
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
                'Recent Sessions',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                  color: AppColors.velvetPale,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentSessions.take(6).map((sessionData) {
            final session = sessionData['session'] as WorkoutSession;
            final split = sessionData['split'] as WorkoutSplit;
            final lastPerformed = sessionData['lastPerformed'] as DateTime?;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  // Start workout with this specific session
                  workoutProvider.startWorkoutFromSplit(split, session).then((_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ActiveWorkoutScreen(),
                      ),
                    );
                  });
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.name,
                              style: const TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              split.name,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 12,
                                color: AppColors.velvetLight.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${session.exercises.length} exercises',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 12,
                              color: AppColors.velvetLight.withOpacity(0.7),
                            ),
                          ),
                          if (lastPerformed != null)
                            Text(
                              _formatLastPerformed(lastPerformed),
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 10,
                                color: AppColors.velvetPale,
                              ),
                            ),
                        ],
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
            );
          }).toList(),
        ],
      ),
    );
  }
  
  String _formatLastPerformed(DateTime lastPerformed) {
    final now = DateTime.now();
    final difference = now.difference(lastPerformed);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Recently';
    }
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
