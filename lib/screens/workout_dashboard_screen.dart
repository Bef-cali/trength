// lib/screens/workout_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/streak_tracker_widget.dart';
import '../widgets/compact_strength_chart_widget.dart';
import '../widgets/recent_workout_stats_widget.dart';
import 'workout_start_screen.dart';
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
      ),
      body: Consumer2<WorkoutProvider, ExerciseProvider>(
        builder: (context, workoutProvider, exerciseProvider, child) {
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkoutStartScreen(),
                        ),
                      );
                    },
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


  



}
