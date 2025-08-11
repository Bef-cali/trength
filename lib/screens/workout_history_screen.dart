// lib/screens/workout_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../providers/exercise_provider.dart';
import '../models/active_workout.dart';
import '../models/exercise_set.dart';
import '../theme/app_colors.dart';
import '../widgets/history/github_calendar_widget.dart';
import '../widgets/history/history_filter_widget.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _splitId;
  String? _exerciseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters({
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

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _splitId = null;
      _exerciseId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: const Text(
          'Workout History',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.royalVelvet,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.velvetMist,
          labelColor: AppColors.velvetMist,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              text: "List View",
              icon: Icon(Icons.view_list),
            ),
            Tab(
              text: "Calendar",
              icon: Icon(Icons.calendar_month),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters indicator
          if (_startDate != null || _endDate != null || _splitId != null || _exerciseId != null)
            _buildActiveFiltersBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // List view tab
                _buildListView(),

                // Calendar view tab
                _buildCalendarView(),
              ],
            ),
          ),
        ],
      ),
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
            onTap: _clearFilters,
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

  Widget _buildListView() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final workouts = workoutProvider.getWorkoutHistory(
          startDate: _startDate,
          endDate: _endDate,
          splitId: _splitId,
          exerciseId: _exerciseId,
        );

        if (workouts.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return _buildWorkoutCard(context, workout);
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return const GitHubCalendarWidget();
  }

  void _showFilterOptions(BuildContext context) {
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
          onApplyFilters: _applyFilters,
        );
      },
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildWorkoutCard(BuildContext context, ActiveWorkout workout) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    // Format date
    final date = DateFormat('EEE, MMM d, y').format(workout.startTime);

    // Format time
    final startTime = DateFormat('h:mm a').format(workout.startTime);
    final endTime = workout.endTime != null
        ? DateFormat('h:mm a').format(workout.endTime!)
        : 'In Progress';

    // Calculate duration
    final duration = workout.duration;
    final durationText = _formatDuration(duration);

    // Get exercise count
    final exerciseCount = workout.exerciseSets.length;

    // Calculate total sets and completed sets
    final totalSets = workout.totalSets;
    final completedSets = workout.completedSets;

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

    // Get first few exercises for preview
    final exerciseNames = workout.exerciseSets.keys
        .take(3)
        .map((id) {
          final exercise = exerciseProvider.getExerciseById(id);
          return exercise?.name ?? 'Unknown Exercise';
        })
        .join(', ');

    // Add ellipsis if there are more exercises
    final exercisePreview = exerciseCount > 3
        ? '$exerciseNames, +${exerciseCount - 3} more'
        : exerciseNames;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.royalVelvet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showWorkoutDetails(context, workout);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout name and date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            color: AppColors.velvetPale,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.velvetHighlight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      durationText,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Exercises', exerciseCount.toString()),
                  _buildStatItem('Sets', '$completedSets/$totalSets'),
                  _buildStatItem('Volume', '${totalVolume.toStringAsFixed(0)} kg'),
                ],
              ),

              const SizedBox(height: 16),

              // Exercise preview
              if (exercisePreview.isNotEmpty)
                Text(
                  exercisePreview,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
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
                      Text(
                        workout.name,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(workout.startTime),
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          color: AppColors.velvetPale,
                        ),
                      ),

                      // Time and duration
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
