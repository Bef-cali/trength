// lib/screens/analytics/analytics_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../models/active_workout.dart';
import '../../models/exercise_set.dart';
import '../../theme/app_colors.dart';
import '../../widgets/analytics/strength_chart_widget.dart';
import '../../widgets/analytics/pr_timeline_widget.dart';
import '../../widgets/history/github_calendar_widget.dart';
import '../../widgets/history/history_filter_widget.dart';
import '../../widgets/history/workout_timeline_widget.dart';
import '../../utils/one_rep_max_calculator.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsDashboardScreenState createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = 'month'; // 'week', 'month', 'year', 'all'
  bool _isLoading = false;
  int _historyViewMode = 0; // 0 = List, 1 = Calendar
  
  // History-related state variables
  DateTime? _startDate;
  DateTime? _endDate;
  String? _splitId;
  String? _exerciseId;
  DateTime _calendarFocusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFocusedDate();
  }

  void _initializeFocusedDate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      final workouts = workoutProvider.getWorkoutHistory();
      
      if (workouts.isNotEmpty) {
        final mostRecentWorkout = workouts.first;
        setState(() {
          _calendarFocusedDate = DateTime(
            mostRecentWorkout.startTime.year,
            mostRecentWorkout.startTime.month,
            1,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      body: Column(
        children: [
          // Custom header with tabs
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    labelStyle: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'ANALYTICS'),
                      Tab(text: 'HISTORY'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Context-aware action button
                if (_tabController.index == 0)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
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
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  )
                else
                  IconButton(
                    onPressed: () {
                      _showHistoryFilterOptions(context);
                    },
                    icon: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
              ],
            ),
          ),
          
          // Active filters indicator for history tab
          if (_tabController.index == 1 && (_startDate != null || _endDate != null || _splitId != null || _exerciseId != null))
            _buildActiveFiltersBar(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalyticsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildAnalyticsTab() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    return _buildAnalyticsBody();
  }

  Widget _buildHistoryTab() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return Column(
          children: [
            // Month name and toggle for List/Calendar view
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Month name with navigation arrows for both views
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        iconSize: 20,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getCurrentDisplayMonth(),
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        iconSize: 20,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                    ],
                  ),
                  
                  // View toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.royalVelvet,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleButton(
                          svgPath: 'assets/images/list.svg',
                          isSelected: _historyViewMode == 0,
                          onTap: () => setState(() => _historyViewMode = 0),
                          isFirst: true,
                        ),
                        _buildToggleButton(
                          svgPath: 'assets/images/calendar-days.svg',
                          isSelected: _historyViewMode == 1,
                          onTap: () => setState(() => _historyViewMode = 1),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content based on selected view
            Expanded(
              child: _historyViewMode == 0 
                ? _buildHistoryListView()
                : _buildHistoryCalendarView(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToggleButton({
    required String svgPath,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.velvetMist : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 8 : 0),
            bottomLeft: Radius.circular(isFirst ? 8 : 0),
            topRight: Radius.circular(isLast ? 8 : 0),
            bottomRight: Radius.circular(isLast ? 8 : 0),
          ),
        ),
        child: SvgPicture.asset(
          svgPath,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  String _getCurrentDisplayMonth() {
    final monthNames = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    
    // Always use the focused date for both views
    return monthNames[_calendarFocusedDate.month - 1];
  }

  void _previousMonth() {
    setState(() {
      _calendarFocusedDate = DateTime(_calendarFocusedDate.year, _calendarFocusedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _calendarFocusedDate = DateTime(_calendarFocusedDate.year, _calendarFocusedDate.month + 1, 1);
    });
  }

  void _onCalendarDateChanged(DateTime date) {
    setState(() {
      _calendarFocusedDate = date;
    });
  }

  void _showHistoryFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.royalVelvet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return HistoryFilterWidget(
          initialStartDate: _startDate,
          initialEndDate: _endDate,
          initialSplitId: _splitId,
          initialExerciseId: _exerciseId,
          onApplyFilters: _applyHistoryFilters,
        );
      },
    );
  }

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.velvetHighlight.withOpacity(0.2),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: AppColors.velvetPale,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filters applied',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: AppColors.velvetPale,
              ),
            ),
          ),
          InkWell(
            onTap: _clearHistoryFilters,
            child: Text(
              'Clear',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.velvetMist,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsBody() {
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

                // Personal Records - moved to top priority
                _buildSectionHeader('Personal Records'),
                Container(
                  height: 300, // Increased height since it's now the main focus
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  child: PRTimelineWidget(
                    personalRecords: analyticsData['recentPRs'] as List<Map<String, dynamic>>?,
                  ),
                ),

                const SizedBox(height: 6),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 24),

                // Strength Progress - moved to second priority
                _buildSectionHeader('Strength Progress'),
                Container(
                  height: 250, // Slightly smaller for secondary chart
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  child: StrengthChartWidget(
                    strengthProgressData: analyticsData['strengthProgress'] as List<Map<String, dynamic>>?,
                  ),
                ),

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

        // Add top performance as a PR with calculated 1RM
        final bestPerformance = performances.first;
        final weight = bestPerformance['weight'] ?? 0;
        final reps = bestPerformance['reps'] ?? 0;
        
        // Calculate 1RM for this performance
        final oneRMResult = OneRepMaxCalculator.calculate(
          weight: weight is int ? weight.toDouble() : weight as double,
          reps: reps is double ? reps.toInt() : reps as int,
          weightUnit: 'kg', // Assuming kg for now
        );
        
        recentPRs.add({
          'exerciseId': exerciseId,
          'exerciseName': exercise.name,
          'weight': weight,
          'reps': reps,
          'oneRM': oneRMResult.oneRepMax,
          'formula': oneRMResult.formulaName,
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

  // History-related methods
  void _applyHistoryFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? splitId,
    String? exerciseId,
  }) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _splitId = splitId;
      _exerciseId = exerciseId;
    });
  }

  void _clearHistoryFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _splitId = null;
      _exerciseId = null;
    });
  }

  Widget _buildHistoryListView() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final allWorkouts = workoutProvider.getWorkoutHistory(
          startDate: _startDate,
          endDate: _endDate,
          splitId: _splitId,
          exerciseId: _exerciseId,
        );

        // Filter workouts to only show those from the focused month
        final workouts = allWorkouts.where((workout) {
          return workout.startTime.year == _calendarFocusedDate.year &&
                 workout.startTime.month == _calendarFocusedDate.month;
        }).toList();

        if (workouts.isEmpty) {
          return _buildHistoryEmptyState();
        }

        return WorkoutTimelineWidget(
          workouts: workouts,
          onWorkoutTap: (workout) => _showWorkoutDetails(context, workout),
        );
      },
    );
  }

  Widget _buildHistoryCalendarView() {
    return GitHubCalendarWidget(
      focusedDate: _calendarFocusedDate,
      onDateChanged: _onCalendarDateChanged,
    );
  }

  Widget _buildHistoryEmptyState() {
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
          const SizedBox(height: 8),
          if (_startDate != null || _endDate != null || _splitId != null || _exerciseId != null)
            Text(
              'Try removing some filters',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: AppColors.velvetLight.withOpacity(0.7),
              ),
            )
          else
            Text(
              'Complete your first workout to see it here',
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


  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m';
    } else {
      return '${duration.inMinutes}m ${(duration.inSeconds % 60).toString().padLeft(2, '0')}s';
    }
  }

  void _showWorkoutDetails(BuildContext context, ActiveWorkout workout) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    // Calculate total volume
    double totalVolume = 0;
    Map<String, double> muscleGroupVolume = {};

    workout.exerciseSets.forEach((exerciseId, sets) {
      final exercise = exerciseProvider.getExerciseById(exerciseId);
      if (exercise != null) {
        for (var set in sets) {
          if (set.completed && !set.isWarmup) {
            final setVolume = set.weight * set.reps;
            totalVolume += setVolume;

            // Add volume to primary muscle groups
            for (var muscle in exercise.primaryMuscles) {
              muscleGroupVolume[muscle] = (muscleGroupVolume[muscle] ?? 0) + setVolume;
            }
          }
        }
      }
    });

    // Get PR count for this workout
    int prCount = 0;
    for (var exerciseId in workout.exerciseSets.keys) {
      final sets = workout.exerciseSets[exerciseId] ?? [];
      for (var set in sets) {
        if (set.completed && !set.isWarmup) {
          if (workoutProvider.isPersonalRecord(exerciseId, set)) {
            prCount++;
            break;  // Count only one PR per exercise
          }
        }
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.royalVelvet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Workout name and date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Centered workout name
                      Center(
                        child: Text(
                          workout.name,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Left-aligned date
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat('EEE, MMM d, y').format(workout.startTime),
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            color: AppColors.velvetPale,
                          ),
                        ),
                      ),

                      // Time and duration
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat('h:mm a').format(workout.startTime)} - ',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              workout.endTime != null
                                  ? DateFormat('h:mm a').format(workout.endTime!)
                                  : 'In Progress',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              ' (${_formatDuration(workout.duration)})',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Analytics summary
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.deepVelvet,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Summary',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.velvetPale,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAnalyticItem('Total Volume', '${totalVolume.toStringAsFixed(0)} kg'),
                          _buildAnalyticItem('Exercises', workout.exerciseSets.length.toString()),
                          _buildAnalyticItem('PRs', prCount.toString()),
                        ],
                      ),

                      // Top muscles worked
                      if (muscleGroupVolume.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Top Muscles Worked',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var entry in muscleGroupVolume.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value))
                              ..take(3))
                            Expanded(
                              child: _buildMuscleVolumeItem(
                                entry.key,
                                entry.value,
                                totalVolume,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(color: Colors.white24),

                // Exercise list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: workout.exerciseSets.length,
                    itemBuilder: (context, index) {
                      final exerciseId = workout.exerciseSets.keys.elementAt(index);
                      final sets = workout.exerciseSets[exerciseId] ?? [];
                      final exercise = exerciseProvider.getExerciseById(exerciseId);

                      // Calculate exercise volume
                      double exerciseVolume = 0;
                      for (var set in sets) {
                        if (set.completed && !set.isWarmup) {
                          exerciseVolume += set.weight * set.reps;
                        }
                      }

                      // Check if any of the sets is a PR
                      bool hasPR = false;
                      for (var set in sets) {
                        if (set.completed && !set.isWarmup) {
                          if (workoutProvider.isPersonalRecord(exerciseId, set)) {
                            hasPR = true;
                            break;
                          }
                        }
                      }

                      return _buildExerciseItem(
                        exercise?.name ?? 'Unknown Exercise',
                        sets,
                        exerciseVolume,
                        hasPR,
                      );
                    },
                  ),
                ),

                // Notes if any
                if (workout.notes != null && workout.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workout.notes!,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleVolumeItem(String muscle, double volume, double totalVolume) {
    final percentage = (volume / totalVolume * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            muscle,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.velvetMist.withOpacity(0.2),
                    width: 3,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.velvetPale,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${volume.toStringAsFixed(0)} kg',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String exerciseName, List<ExerciseSet> sets, double volume, bool hasPR) {
    final completedSets = sets.where((set) => set.completed).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name and set count
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      exerciseName,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (hasPR)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.velvetMist,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PR',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${volume.toStringAsFixed(0)} kg · $completedSets/${sets.length} sets',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: AppColors.velvetPale,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Sets table
          Container(
            decoration: BoxDecoration(
              color: AppColors.deepVelvet,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const SizedBox(width: 32, child: Center(child: Text('Set', style: TextStyle(fontFamily: 'Quicksand', fontSize: 12, color: Colors.white70)))),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Weight', style: TextStyle(fontFamily: 'Quicksand', fontSize: 12, color: Colors.white70))),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Reps', style: TextStyle(fontFamily: 'Quicksand', fontSize: 12, color: Colors.white70))),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('RPE', style: TextStyle(fontFamily: 'Quicksand', fontSize: 12, color: Colors.white70))),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Colors.white24),

                // Set rows
                ...sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;

                  // Skip sets that weren't completed
                  if (!set.completed) return const SizedBox.shrink();

                  final bgColor = index.isEven
                      ? Colors.transparent
                      : AppColors.royalVelvet.withOpacity(0.3);

                  Color textColor = Colors.white;
                  if (set.isWarmup) {
                    textColor = Colors.white70;
                  } else if (set.isDropSet) {
                    textColor = AppColors.velvetPale;
                  }

                  return Container(
                    color: bgColor,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Set number
                        SizedBox(
                          width: 32,
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Weight
                        Expanded(
                          child: Text(
                            '${set.weight} ${set.weightUnit}',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Reps
                        Expanded(
                          child: Text(
                            '${set.reps}',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // RPE
                        Expanded(
                          child: Text(
                            set.rpe?.toString() ?? '-',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
