// lib/screens/analytics/analytics_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/analytics/volume_chart_widget.dart';
import '../../widgets/analytics/strength_chart_widget.dart';
import '../../widgets/analytics/pr_timeline_widget.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsDashboardScreenState createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _timeRange = 'month'; // 'week', 'month', 'year', 'all'
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.royalVelvet,
        elevation: 4, // Added elevation for visual separation
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() {
                _timeRange = value;
              });
            },
            itemBuilder: (context) => [
              _buildPopupMenuItem('week', 'This Week'),
              _buildPopupMenuItem('month', 'This Month'),
              _buildPopupMenuItem('year', 'This Year'),
              _buildPopupMenuItem('all', 'All Time'),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildBody(),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: _timeRange == value ? AppColors.velvetMist : Colors.transparent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: _timeRange == value ? AppColors.velvetMist : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.velvetPale),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer2<WorkoutProvider, ExerciseProvider>(
      builder: (context, workoutProvider, exerciseProvider, child) {
        final workouts = _getFilteredWorkouts(workoutProvider);

        if (workouts.isEmpty) {
          return _buildEmptyState();
        }

        // Extract and compute analytics data from workout history
        Map<String, dynamic> analyticsData = {};
        try {
          analyticsData = _computeAnalyticsData(workouts, exerciseProvider);
        } catch (e, stacktrace) {
          debugPrint('Error computing analytics data: $e');
          debugPrint('Stack trace: $stacktrace');

          // Initialize with basic data
          analyticsData = {
            'totalWorkouts': workouts.length,
            'totalVolume': 0.0,
            'exercisesUsed': 0,
            'muscleGroupVolume': <String, double>{},
            'strengthProgress': <Map<String, dynamic>>[],
            'recentPRs': <Map<String, dynamic>>[],
            'avgDuration': const Duration(minutes: 0),
            'dayFrequency': <String, int>{
              'Monday': 0, 'Tuesday': 0, 'Wednesday': 0,
              'Thursday': 0, 'Friday': 0, 'Saturday': 0, 'Sunday': 0,
            },
          };
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Show loading state
            setState(() {
              _isLoading = true;
            });

            // Small delay to ensure UI updates
            await Future.delayed(const Duration(milliseconds: 100));

            // End loading state
            setState(() {
              _isLoading = false;
            });
          },
          color: AppColors.velvetMist,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time period indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.velvetHighlight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Text(
                    'Showing data for: ${_getTimeRangeText()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Summary cards
                _buildSummaryCards(analyticsData),

                const SizedBox(height: 24),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 24),

                // Volume by Muscle Group
                _buildSectionHeader('Volume by Muscle Group'),
                Container(
                  height: 300,
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  child: VolumeChartWidget(
                    muscleGroupVolume: analyticsData['muscleGroupVolume'] as Map<String, double>?,
                  ),
                ),

                // Recent PRs
                _buildSectionHeader('Recent Personal Records'),
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  child: PRTimelineWidget(
                    personalRecords: analyticsData['recentPRs'] as List<Map<String, dynamic>>?,
                  ),
                ),

                const SizedBox(height: 6),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 24),

                // Top exercises by strength progress
                _buildSectionHeader('Strength Progress'),
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  child: StrengthChartWidget(
                    strengthProgressData: analyticsData['strengthProgress'] as List<Map<String, dynamic>>?,
                  ),
                ),

                // Workout frequency
                _buildSectionHeader('Workout Frequency'),
                _buildFrequencyCard(analyticsData),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _getFilteredWorkouts(WorkoutProvider workoutProvider) {
    final now = DateTime.now();
    DateTime? startDate;

    // Determine the start date based on selected time range
    switch (_timeRange) {
      case 'week':
        // Start of current week (Monday)
        int daysToSubtract = now.weekday - 1;
        if (daysToSubtract < 0) daysToSubtract += 7;
        startDate = DateTime(now.year, now.month, now.day - daysToSubtract);
        break;
      case 'month':
        // Start of current month
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        // Start of current year
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'all':
        // No start date filter
        startDate = null;
        break;
    }

    try {
      return workoutProvider.getWorkoutHistory(startDate: startDate);
    } catch (e) {
      // Handle any errors in the provider
      debugPrint('Error getting workout history: $e');
      return [];
    }
  }

  Map<String, dynamic> _computeAnalyticsData(
      List<dynamic> workouts, ExerciseProvider exerciseProvider) {
    // Initialize analytics data structure with defaults
    Map<String, dynamic> analyticsData = {
      'totalWorkouts': workouts.length,
      'totalVolume': 0.0,
      'exercisesUsed': 0,
      'muscleGroupVolume': <String, double>{},
      'strengthProgress': <Map<String, dynamic>>[],
      'recentPRs': <Map<String, dynamic>>[],
      'avgDuration': const Duration(minutes: 0),
      'dayFrequency': <String, int>{
        'Monday': 0, 'Tuesday': 0, 'Wednesday': 0,
        'Thursday': 0, 'Friday': 0, 'Saturday': 0, 'Sunday': 0,
      },
    };

    try {
      // Basic counters and accumulators
      double totalVolume = 0;
      Map<String, double> muscleGroupVolume = {};
      Map<String, List<Map<String, dynamic>>> exercisePerformance = {};

      // Debug variables to help identify issues
      int processedWorkouts = 0;
      int processedExercises = 0;
      int processedSets = 0;

      // Process each workout
      for (var workout in workouts) {
        processedWorkouts++;

        // First check if workout is valid and has exercise sets
        if (workout == null || workout.exerciseSets == null) {
          debugPrint('Skipping invalid workout at index ${processedWorkouts-1}');
          continue;
        }

        // Track workout frequency by day of week
        if (workout.startTime != null) {
          final day = _getDayName(workout.startTime.weekday);
          analyticsData['dayFrequency'][day] = (analyticsData['dayFrequency'][day] ?? 0) + 1;
        }

        // Calculate duration totals for averages
        if (workout.isCompleted && workout.endTime != null && workout.startTime != null) {
          final duration = workout.endTime!.difference(workout.startTime);
          analyticsData['avgDuration'] = analyticsData['avgDuration'] is Duration
              ? (analyticsData['avgDuration'] as Duration) + duration
              : duration;
        }

        // Process each exercise in the workout
        workout.exerciseSets.forEach((exerciseId, sets) {
          processedExercises++;

          // Skip if exercise ID or sets are invalid
          if (exerciseId == null || sets == null || sets.isEmpty) {
            debugPrint('Skipping invalid exercise sets for workout ${processedWorkouts-1}');
            return; // Using return in forEach acts like continue
          }

          // Get exercise data
          final exercise = exerciseProvider.getExerciseById(exerciseId);
          if (exercise == null) {
            debugPrint('Exercise with ID $exerciseId not found');
            return; // Skip this iteration
          }

          // Initialize exercise performance tracking if needed
          if (!exercisePerformance.containsKey(exerciseId)) {
            exercisePerformance[exerciseId] = [];
          }

          // Process and filter sets
          var workingSets = sets.where((s) {
            return s != null && s.completed == true && s.isWarmup == false;
          }).toList();

          if (workingSets.isEmpty) {
            return; // No valid sets, skip this exercise
          }

          // FIXED: Find the best set without using sort to avoid type errors
          var bestSet;
          if (workingSets.isNotEmpty) {
            // Start with first set as best
            bestSet = workingSets[0];

            // Find set with highest weight
            for (var i = 1; i < workingSets.length; i++) {
              var currentSet = workingSets[i];
              if (currentSet.weight != null &&
                 (bestSet.weight == null || currentSet.weight > bestSet.weight)) {
                bestSet = currentSet;
              }
            }
          } else {
            return; // Skip if no working sets
          }

          // Only record if weight and reps are valid
          if (bestSet != null && bestSet.weight != null && bestSet.weight > 0 &&
              bestSet.reps != null && bestSet.reps > 0) {

            // Record performance for this workout
            exercisePerformance[exerciseId]!.add({
              'date': workout.startTime,
              'weight': bestSet.weight,
              'reps': bestSet.reps,
              'exercise': exercise.name,
            });

            // Process volume - iterate through all working sets
            for (var set in workingSets) {
              processedSets++;
              if (set.weight != null && set.reps != null) {
                final setVolume = set.weight * set.reps;
                totalVolume += setVolume;

                // Add volume to primary muscle groups if they exist
                if (exercise.primaryMuscles != null && exercise.primaryMuscles.isNotEmpty) {
                  for (var muscle in exercise.primaryMuscles) {
                    if (muscle != null && muscle.isNotEmpty) {
                      muscleGroupVolume[muscle] = (muscleGroupVolume[muscle] ?? 0) + setVolume;
                    }
                  }
                }
              }
            }
          }
        });
      }

      // Store the calculated values
      analyticsData['totalVolume'] = totalVolume;
      analyticsData['muscleGroupVolume'] = muscleGroupVolume;
      analyticsData['exercisesUsed'] = exercisePerformance.keys.length;

      // Calculate average workout duration
      if (analyticsData['avgDuration'] is Duration && processedWorkouts > 0) {
        analyticsData['avgDuration'] =
            (analyticsData['avgDuration'] as Duration) ~/ processedWorkouts;
      } else {
        analyticsData['avgDuration'] = const Duration(minutes: 0);
      }

      // Calculate strength progress for exercises
      List<Map<String, dynamic>> strengthProgress = [];
      exercisePerformance.forEach((exerciseId, performances) {
        if (performances.length >= 2) {
          // Sort by date safely
          performances.sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1; // null dates come last
            if (dateB == null) return -1;
            return dateA.compareTo(dateB); // ascending date order
          });

          final firstPerformance = performances.first;
          final lastPerformance = performances.last;

          // Get weights with safety checks
          final firstWeight = firstPerformance['weight'] ?? 0.0;
          final lastWeight = lastPerformance['weight'] ?? 0.0;

          // Calculate progress
          double weightDiff = 0.0;
          double percentIncrease = 0.0;

          try {
            weightDiff = (lastWeight is num ? lastWeight.toDouble() : 0.0) -
                        (firstWeight is num ? firstWeight.toDouble() : 0.0);

            if (firstWeight is num && firstWeight > 0) {
              percentIncrease = (weightDiff / firstWeight.toDouble() * 100);
            }
          } catch (e) {
            debugPrint('Error calculating progress for $exerciseId: $e');
          }

          strengthProgress.add({
            'exerciseId': exerciseId,
            'exerciseName': lastPerformance['exercise'] ?? 'Unknown',
            'startWeight': firstWeight,
            'currentWeight': lastWeight,
            'increase': weightDiff,
            'percentIncrease': percentIncrease,
            'performances': performances,
          });
        }
      });

      // Sort strength progress by percentage, null-safe
      strengthProgress.sort((a, b) {
        final percentA = a['percentIncrease'] as double?;
        final percentB = b['percentIncrease'] as double?;

        if (percentA == null && percentB == null) return 0;
        if (percentA == null) return 1; // null values at the end
        if (percentB == null) return -1;
        return percentB.compareTo(percentA); // descending order
      });

      analyticsData['strengthProgress'] = strengthProgress;

      // Compile personal records
      List<Map<String, dynamic>> recentPRs = [];
      exercisePerformance.forEach((exerciseId, performances) {
        if (performances.isEmpty) return;

        final exercise = exerciseProvider.getExerciseById(exerciseId);
        if (exercise == null) return;

        // Sort by weight first, then by reps (descending)
        performances.sort((a, b) {
          final weightA = a['weight'] as num?;
          final weightB = b['weight'] as num?;

          // Handle null weights
          if (weightA == null && weightB == null) return 0;
          if (weightA == null) return 1;
          if (weightB == null) return -1;

          // If weights are equal, sort by reps
          final weightComp = weightB.compareTo(weightA);
          if (weightComp == 0) {
            final repsA = a['reps'] as num?;
            final repsB = b['reps'] as num?;

            if (repsA == null && repsB == null) return 0;
            if (repsA == null) return 1;
            if (repsB == null) return -1;

            return repsB.compareTo(repsA);
          }
          return weightComp;
        });

        // Add top performance as a PR
        final bestPerformance = performances.first;
        recentPRs.add({
          'exerciseId': exerciseId,
          'exerciseName': exercise.name,
          'weight': bestPerformance['weight'] ?? 0,
          'reps': bestPerformance['reps'] ?? 0,
          'date': bestPerformance['date'] ?? DateTime.now(),
        });
      });

      // Sort PRs by date, newest first
      recentPRs.sort((a, b) {
        final dateA = a['date'] as DateTime?;
        final dateB = b['date'] as DateTime?;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

      analyticsData['recentPRs'] = recentPRs;

      // Debug output
      debugPrint('Analytics completed: ${processedWorkouts} workouts, ' +
                '${processedExercises} exercises, ${processedSets} sets');
      debugPrint('Muscle groups: ${muscleGroupVolume.keys.length}, ' +
                'Strength progress: ${strengthProgress.length} entries, ' +
                'PRs: ${recentPRs.length} entries');

    } catch (e, stackTrace) {
      // Log detailed error information
      debugPrint('Error computing analytics data: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    return analyticsData;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: AppColors.velvetLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No workout data available',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.velvetLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete workouts to see your analytics',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              color: AppColors.velvetLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.velvetPale,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    final totalWorkouts = data['totalWorkouts'] ?? 0;
    final totalVolume = data['totalVolume'] ?? 0.0;
    final exercisesUsed = data['exercisesUsed'] ?? 0;
    final avgDuration = data['avgDuration'] as Duration?;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Workouts',
          totalWorkouts.toString(),
          Icons.fitness_center,
        ),
        _buildSummaryCard(
          'Total Volume',
          '${totalVolume.toStringAsFixed(0)} kg',
          Icons.bar_chart,
        ),
        _buildSummaryCard(
          'Exercises Used',
          exercisesUsed.toString(),
          Icons.sports_gymnastics,
        ),
        _buildSummaryCard(
          'Avg Duration',
          avgDuration != null
              ? '${avgDuration.inMinutes} min'
              : '0 min',
          Icons.timer,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: AppColors.velvetPale,
            size: 28,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyCard(Map<String, dynamic> data) {
    final dayFrequency = data['dayFrequency'] as Map<String, int>?;
    if (dayFrequency == null || dayFrequency.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find max value safely
    int maxValue = 0;
    dayFrequency.values.forEach((v) {
      if (v > maxValue) maxValue = v;
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workouts by Day',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _getTimeRangeText(),
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
                _buildDayFrequencyBar(
                  day.substring(0, 1),
                  maxValue > 0 ? 100 * (dayFrequency[day]! / maxValue) : 0.0,
                  dayFrequency[day] ?? 0
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayFrequencyBar(String day, double height, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.velvetHighlight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white12),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 24,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.velvetPale,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
                bottom: Radius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getTimeRangeText() {
    switch (_timeRange) {
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      case 'all':
        return 'All Time';
      default:
        return '';
    }
  }
}
