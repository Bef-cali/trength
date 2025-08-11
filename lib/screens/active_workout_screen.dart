// lib/screens/active_workout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/active_workout.dart';
import '../models/exercise_set.dart';
import '../providers/workout_provider.dart';
import '../providers/exercise_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/exercise_set_card.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/progression_suggestion_chip.dart';
import '../widgets/personal_record_celebration.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({Key? key}) : super(key: key);

  @override
  _ActiveWorkoutScreenState createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  // Track which exercise is expanded (if any)
  String? expandedExerciseId;
  // Track if PR celebration is showing
  bool _showingPRCelebration = false;

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    final currentWorkout = workoutProvider.currentWorkout;

    if (currentWorkout == null) {
      return Scaffold(
        backgroundColor: AppColors.deepVelvet,
        appBar: AppBar(
          title: const Text('Workout'),
          backgroundColor: AppColors.royalVelvet,
        ),
        body: const Center(
          child: Text('No active workout', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // Get all exercises in the workout
    final exerciseIds = currentWorkout.exerciseSets.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: Text(currentWorkout.name),
        backgroundColor: AppColors.royalVelvet,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddExerciseDialog(context, workoutProvider, exerciseProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _showCompleteDialog(context, workoutProvider);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Rest timer
              if (workoutProvider.isRestTimerActive || workoutProvider.restTimerSeconds > 0)
                RestTimerWidget(
                  seconds: workoutProvider.restTimerSeconds,
                  isActive: workoutProvider.isRestTimerActive,
                  onPause: workoutProvider.pauseRestTimer,
                  onResume: workoutProvider.resumeRestTimer,
                  onCancel: workoutProvider.cancelRestTimer,
                ),

              // Exercise list with sets
              Expanded(
                child: exerciseIds.isEmpty
                    ? _buildEmptyWorkoutView(context, workoutProvider, exerciseProvider)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: exerciseIds.length,
                        itemBuilder: (context, index) {
                          final exerciseId = exerciseIds[index];
                          final exercise = exerciseProvider.getExerciseById(exerciseId);
                          final sets = currentWorkout.exerciseSets[exerciseId] ?? [];
                          final isExpanded = expandedExerciseId == exerciseId;

                          if (exercise == null) return const SizedBox.shrink();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: AppColors.royalVelvet,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Exercise header (tappable to expand/collapse)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        expandedExerciseId = null;
                                      } else {
                                        expandedExerciseId = exerciseId;
                                        // Optional: set the current exercise in the provider
                                        workoutProvider.selectExercise(exerciseId);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                exercise.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                sets.isEmpty
                                                    ? 'No sets'
                                                    : '${sets.length} sets',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Sets (only visible when expanded)
                                if (isExpanded) ...[
                                  const Divider(height: 1, color: Colors.white24),
                                  // Get previous performance data for this exercise
                                  _buildPreviousPerformanceSection(
                                    workoutProvider,
                                    exerciseId
                                  ),

                                  // List of sets
                                  if (sets.isEmpty)
                                    _buildEmptySetsView(context, workoutProvider, exerciseId)
                                  else
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: sets.length,
                                      itemBuilder: (context, setIndex) {
                                        final set = sets[setIndex];

                                        // Check if this set is a PR and get comparison
                                        final isPR = !set.isWarmup && set.completed &&
                                                    workoutProvider.isPersonalRecord(exerciseId, set);

                                        // Get comparison with previous performance
                                        final comparison = set.completed ?
                                            workoutProvider.compareWithPrevious(exerciseId, set) : null;

                                        return ExerciseSetCard(
                                          exerciseId: exerciseId,
                                          set: set,
                                          setNumber: setIndex + 1,
                                          isPR: isPR,
                                          progressComparison: comparison,
                                          onSetCompleted: (completed) {
                                            workoutProvider.markSetComplete(
                                              exerciseId, set.id, completed);

                                            // Start rest timer if set was completed
                                            if (completed) {
                                              workoutProvider.startRestTimer(90); // Default 90 seconds

                                              // Check if this set is a PR after completion
                                              if (!set.isWarmup &&
                                                workoutProvider.isPersonalRecord(exerciseId, set)) {
                                                _showPRCelebration(context, exercise.name);
                                              }
                                            }
                                          },
                                          onSetEdited: (updatedSet) {
                                            workoutProvider.updateSet(
                                              exerciseId, updatedSet);
                                          },
                                          onSetDeleted: () {
                                            workoutProvider.removeSet(
                                              exerciseId, set.id);
                                          },
                                        );
                                      },
                                    ),

                                  // Add set button (only for expanded exercise)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add Set'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.velvetHighlight,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size.fromHeight(50),
                                            ),
                                            onPressed: () => _showAddSetDialog(
                                              context, workoutProvider, exerciseId),
                                          ),
                                        ),
                                        if (sets.isNotEmpty)
                                          IconButton(
                                            icon: const Icon(Icons.content_copy, color: Colors.white70),
                                            onPressed: () {
                                              workoutProvider.duplicateLatestSet(exerciseId);
                                            },
                                            tooltip: 'Duplicate Last Set',
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // PR Celebration overlay (conditionally displayed)
          if (_showingPRCelebration)
            PersonalRecordCelebration(
              onClose: () {
                setState(() {
                  _showingPRCelebration = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPreviousPerformanceSection(
      WorkoutProvider workoutProvider, String exerciseId) {
    final previousSets = workoutProvider.getPreviousSets(exerciseId);
    final bestSet = workoutProvider.getBestSet(exerciseId);

    // Get progression suggestion
    final suggestion = workoutProvider.getSuggestedProgression(exerciseId);

    // Check for plateaus
    final plateauCheck = workoutProvider.checkForPlateauAndSuggestDeload(exerciseId);
    final isPlateaued = plateauCheck['isPlateaued'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.velvetHighlight.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Previous Performance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Last workout
              if (previousSets.isNotEmpty)
                Expanded(
                  child: _buildPreviousPerformanceCard(
                    previousSets.first,
                    'Latest',
                  ),
                ),
              const SizedBox(width: 8),
              // Personal best
              if (bestSet != null)
                Expanded(
                  child: _buildPreviousPerformanceCard(
                    bestSet,
                    'PR',
                    isPR: true,
                  ),
                ),
            ],
          ),

          // Progression suggestion section
          if (suggestion.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Suggested Next Set',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                if (isPlateaued)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Plateau Detected',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressionSuggestionChip(
              exerciseId: exerciseId,
              suggestion: isPlateaued
                  ? plateauCheck['deloadSuggestion'] as Map<String, dynamic>
                  : suggestion,
              isDeload: isPlateaued,
              onApply: (ExerciseSet newSet) {
                workoutProvider.addSet(exerciseId, newSet);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviousPerformanceCard(ExerciseSet set, String label, {bool isPR = false}) {
    final backgroundColor = isPR
        ? AppColors.velvetPale.withOpacity(0.2)
        : AppColors.velvetHighlight.withOpacity(0.2);

    final labelColor = isPR
        ? AppColors.velvetMist
        : Colors.white70;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${set.weight} ${set.weightUnit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '× ${set.reps} reps',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (set.rpe != null)
            Text(
              'RPE: ${set.rpe}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkoutView(
    BuildContext context,
    WorkoutProvider provider,
    ExerciseProvider exerciseProvider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.velvetLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No exercises added yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add exercises to get started',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.velvetHighlight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: () {
              _showAddExerciseDialog(context, provider, exerciseProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySetsView(
    BuildContext context,
    WorkoutProvider provider,
    String exerciseId,
  ) {
    // Get progression suggestion if available
    final suggestion = provider.getSuggestedProgression(exerciseId);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline,
            size: 36,
            color: AppColors.velvetLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'No sets recorded',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          suggestion.isEmpty
              ? const Text(
                  'Tap below to add your first set',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                )
              : const Text(
                  'Use suggested progression or add custom set',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
        ],
      ),
    );
  }

  void _showAddSetDialog(
    BuildContext context,
    WorkoutProvider provider,
    String exerciseId,
  ) {
    final formKey = GlobalKey<FormState>();
    double weight = 0;
    int reps = 0;
    double? rpe;
    bool isWarmup = false;

    // Get the previous sets for this exercise
    final exerciseSets = provider.currentWorkout?.exerciseSets[exerciseId] ?? [];

    // Get progression suggestion if available
    final suggestion = provider.getSuggestedProgression(exerciseId);

    // Pre-fill with values from the latest set or suggestion
    if (exerciseSets.isNotEmpty) {
      final latestSet = exerciseSets.last;
      weight = latestSet.weight;
      reps = latestSet.reps;
      rpe = latestSet.rpe;
      isWarmup = latestSet.isWarmup;
    } else if (suggestion.isNotEmpty) {
      // Use suggestion for first set
      weight = suggestion['weight'];
      reps = suggestion['reps'];
      rpe = suggestion['rpe'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: const Text(
          'Add Set',
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progression suggestion chip (if available)
                if (suggestion.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.velvetPale.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.velvetPale.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: AppColors.velvetPale,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Suggested:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${suggestion['weight']} ${suggestion['weightUnit']} × ${suggestion['reps']} reps',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  color: AppColors.velvetMist,
                                ),
                              ),
                              onPressed: () {
                                final newSet = ExerciseSet(
                                  weight: suggestion['weight'],
                                  weightUnit: suggestion['weightUnit'],
                                  reps: suggestion['reps'],
                                  rpe: suggestion['rpe'],
                                );
                                provider.addSet(exerciseId, newSet);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        if (suggestion['strategy'] != null)
                          Text(
                            suggestion['strategy'],
                            style: const TextStyle(
                              color: AppColors.velvetPale,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Or enter custom values:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Weight input
                TextFormField(
                  initialValue: weight > 0 ? weight.toString() : '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    weight = double.parse(value!);
                  },
                ),
                const SizedBox(height: 16),

                // Reps input
                TextFormField(
                  initialValue: reps > 0 ? reps.toString() : '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reps';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    reps = int.parse(value!);
                  },
                ),
                const SizedBox(height: 16),

                // RPE input
                TextFormField(
                  initialValue: rpe?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RPE (optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    hintText: '1-10',
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final rpeValue = double.tryParse(value);
                      if (rpeValue == null) {
                        return 'Please enter a valid number';
                      }
                      if (rpeValue < 1 || rpeValue > 10) {
                        return 'RPE must be between 1 and 10';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      rpe = double.parse(value);
                    } else {
                      rpe = null;
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Warmup checkbox
                SwitchListTile(
                  title: const Text(
                    'Warmup Set',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: isWarmup,
                  activeColor: AppColors.velvetPale,
                  onChanged: (value) {
                    isWarmup = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Add',
              style: TextStyle(color: AppColors.velvetMist),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                // Create and add the set
                final newSet = ExerciseSet(
                  weight: weight,
                  reps: reps,
                  rpe: rpe,
                  isWarmup: isWarmup,
                );

                provider.addSet(exerciseId, newSet);
                Navigator.of(context).pop();
              }
            },
          ),
          if (exerciseSets.isNotEmpty)
            TextButton(
              child: const Text(
                'Duplicate Last',
                style: TextStyle(color: AppColors.velvetPale),
              ),
              onPressed: () {
                provider.duplicateLatestSet(exerciseId);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
    ExerciseProvider exerciseProvider,
  ) {
    // This list will hold filtered exercises
    List<dynamic> filteredExercises = exerciseProvider.exercises;
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter exercises based on search query
            if (searchQuery.isNotEmpty) {
              filteredExercises = exerciseProvider.exercises
                  .where((e) => e.name.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();
            } else {
              filteredExercises = exerciseProvider.exercises;
            }

            return AlertDialog(
              backgroundColor: AppColors.royalVelvet,
              title: Text(
                'Add Exercise',
                style: TextStyle(color: Colors.white),
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search input
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Exercise list
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];

                          return ListTile(
                            title: Text(
                              exercise.name,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              exercise.category,
                              style: TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              // Add this exercise to the workout
                              if (workoutProvider.currentWorkout != null) {
                                workoutProvider.currentWorkout!.exerciseSets
                                    .putIfAbsent(exercise.id, () => []);
                                // Optionally expand this exercise
                                setState(() {
                                  expandedExerciseId = exercise.id;
                                });
                                workoutProvider.selectExercise(exercise.id);
                              }
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCompleteDialog(
    BuildContext context,
    WorkoutProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: Text(
          'Complete Workout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to complete this workout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'Complete',
              style: TextStyle(color: AppColors.velvetMist),
            ),
            onPressed: () {
              provider.completeWorkout();
              Navigator.pop(context);
              Navigator.pop(context); // Return to the previous screen
            },
          ),
        ],
      ),
    );
  }

  void _showPRCelebration(BuildContext context, String exerciseName) {
    if (!_showingPRCelebration) {
      setState(() {
        _showingPRCelebration = true;
      });

      // Automatically dismiss the celebration after a few seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showingPRCelebration) {
          setState(() {
            _showingPRCelebration = false;
          });
        }
      });
    }
  }
}
