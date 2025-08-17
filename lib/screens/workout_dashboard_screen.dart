// lib/screens/workout_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/split_provider.dart';
import '../models/workout_split.dart';
import '../theme/app_colors.dart';
import '../widgets/streak_tracker_widget.dart';
import '../widgets/compact_strength_chart_widget.dart';
import '../widgets/recent_workout_stats_widget.dart';
import 'exercise_browse_screen.dart';
import 'progression_settings_screen.dart';
import 'active_workout_screen.dart';

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
      ),
      body: Consumer3<WorkoutProvider, ExerciseProvider, SplitProvider>(
        builder: (context, workoutProvider, exerciseProvider, splitProvider, child) {
          final strengthData = _getStrengthProgressData(workoutProvider, exerciseProvider);
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 7-day streak tracker
                const StreakTrackerWidget(),
                const SizedBox(height: 16),
                
                // Strength chart
                CompactStrengthChartWidget(strengthProgressData: strengthData),
                const SizedBox(height: 16),
                
                // Recent workout stats
                const RecentWorkoutStatsWidget(),
                const SizedBox(height: 20),
                
                // Start workout button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showStartWorkoutModal(context, splitProvider, workoutProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.velvetHighlight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start workout',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>>? _getStrengthProgressData(WorkoutProvider workoutProvider, ExerciseProvider exerciseProvider) {
    final workouts = workoutProvider.getWorkoutHistory();
    if (workouts.isEmpty) return null;
    
    Map<String, List<Map<String, dynamic>>> exercisePerformance = {};
    
    // Process workouts to extract exercise performance data
    for (var workout in workouts) {
      if (workout?.exerciseSets == null) continue;
      
      workout.exerciseSets.forEach((exerciseId, sets) {
        if (exerciseId == null || sets == null || sets.isEmpty) return;
        
        final exercise = exerciseProvider.getExerciseById(exerciseId);
        if (exercise == null) return;
        
        if (!exercisePerformance.containsKey(exerciseId)) {
          exercisePerformance[exerciseId] = [];
        }
        
        var workingSets = sets.where((s) => s?.completed == true && s?.isWarmup == false).toList();
        if (workingSets.isEmpty) return;
        
        // Find best set
        var bestSet = workingSets.first;
        for (var set in workingSets) {
          if (set?.weight != null && (bestSet?.weight == null || set.weight > bestSet.weight)) {
            bestSet = set;
          }
        }
        
        if (bestSet?.weight != null && bestSet.weight > 0) {
          exercisePerformance[exerciseId]!.add({
            'date': workout.startTime,
            'weight': bestSet.weight,
            'reps': bestSet.reps ?? 0,
            'exercise': exercise.name,
          });
        }
      });
    }
    
    // Calculate progress for each exercise
    List<Map<String, dynamic>> strengthProgress = [];
    exercisePerformance.forEach((exerciseId, performances) {
      if (performances.length >= 2) {
        performances.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        
        final firstWeight = performances.first['weight'] ?? 0.0;
        final lastWeight = performances.last['weight'] ?? 0.0;
        final weightDiff = lastWeight - firstWeight;
        final percentIncrease = firstWeight > 0 ? (weightDiff / firstWeight * 100) : 0.0;
        
        strengthProgress.add({
          'exerciseId': exerciseId,
          'exerciseName': performances.last['exercise'] ?? 'Unknown',
          'startWeight': firstWeight,
          'currentWeight': lastWeight,
          'increase': weightDiff,
          'percentIncrease': percentIncrease,
          'performances': performances,
        });
      }
    });
    
    // Sort by percentage increase (best progress first)
    strengthProgress.sort((a, b) => (b['percentIncrease'] as double).compareTo(a['percentIncrease'] as double));
    
    return strengthProgress.isEmpty ? null : strengthProgress;
  }

  void _showStartWorkoutModal(BuildContext context, SplitProvider splitProvider, WorkoutProvider workoutProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.deepVelvet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start Workout',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Content based on splits availability
            Expanded(
              child: Consumer<SplitProvider>(
                builder: (context, splitProvider, child) {
                  final splits = splitProvider.splits;
                  
                  if (splits.isEmpty) {
                    return _buildEmptyState(context, workoutProvider);
                  } else {
                    return _buildSplitsList(context, splits, workoutProvider);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WorkoutProvider workoutProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.velvetHighlight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.add,
              size: 40,
              color: AppColors.velvetHighlight,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No splits created yet',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a split to organize your workouts',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/create-split');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Split'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.velvetHighlight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _startEmptyWorkout(context, workoutProvider),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Empty Workout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitsList(BuildContext context, List<WorkoutSplit> splits, WorkoutProvider workoutProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a split',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: splits.length + 1, // +1 for empty workout option
            itemBuilder: (context, index) {
              if (index == splits.length) {
                return _buildEmptyWorkoutCard(context, workoutProvider);
              }
              
              final split = splits[index];
              return _buildSplitCard(context, split, workoutProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSplitCard(BuildContext context, WorkoutSplit split, WorkoutProvider workoutProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.royalVelvet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _startWorkoutFromSplit(context, split, workoutProvider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.velvetHighlight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.velvetHighlight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      '${split.exercises.length} exercises',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWorkoutCard(BuildContext context, WorkoutProvider workoutProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.royalVelvet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => _startEmptyWorkout(context, workoutProvider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Empty Workout',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Start with a blank workout',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWorkoutFromSplit(BuildContext context, WorkoutSplit split, WorkoutProvider workoutProvider) {
    final allExercises = split.exercises.map((ref) => ref.exerciseId).toList();

    workoutProvider.startWorkoutFromSplitDirect(split.name, allExercises).then((_) {
      Navigator.pop(context); // Close modal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ActiveWorkoutScreen(),
        ),
      );
    }).catchError((error) {
      Navigator.pop(context); // Close modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start workout: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _startEmptyWorkout(BuildContext context, WorkoutProvider workoutProvider) {
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[now.weekday - 1];
    final workoutName = '$dayName Workout';

    workoutProvider.startEmptyWorkout(workoutName).then((_) {
      Navigator.pop(context); // Close modal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ActiveWorkoutScreen(),
        ),
      );
    }).catchError((error) {
      Navigator.pop(context); // Close modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start workout: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}
