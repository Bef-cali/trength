// lib/providers/workout_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/active_workout.dart';
import '../models/exercise_set.dart';
import '../models/personal_record.dart';
import '../models/progression_settings.dart';
import '../models/workout_split.dart';
import '../models/workout_session.dart';
import '../repositories/workout_repository.dart';
import '../utils/one_rep_max_calculator.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutRepository _repository;
  final String _settingsBoxName = 'settings';

  // Active workout related properties
  ActiveWorkout? _currentWorkout;
  String? _currentExerciseId;
  int _restTimerSeconds = 0;
  bool _isRestTimerActive = false;

  // Progressive overload settings
  Map<String, dynamic>? _progressionSettings;
  bool _isInitialized = false;
  
  // Beginner mode setting
  bool _isBeginnerMode = true;

  WorkoutProvider(this._repository) {
    _initSettings();
  }

  // Initialize settings from storage
  Future<void> _initSettings() async {
    try {
      if (!Hive.isBoxOpen(_settingsBoxName)) {
        await Hive.openBox(_settingsBoxName);
      }

      final box = Hive.box(_settingsBoxName);
      final savedSettings = box.get('progressionSettings');

      if (savedSettings != null) {
        _progressionSettings = Map<String, dynamic>.from(savedSettings);
      }
      
      // Load beginner mode setting
      _isBeginnerMode = box.get('isBeginnerMode', defaultValue: true);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing settings: $e');
      // Fall back to defaults if there's an error
      _isInitialized = true;
    }
  }

  // Getters for current state
  ActiveWorkout? get currentWorkout => _currentWorkout;
  String? get currentExerciseId => _currentExerciseId;
  int get restTimerSeconds => _restTimerSeconds;
  bool get isRestTimerActive => _isRestTimerActive;
  bool get isInitialized => _isInitialized;
  bool get isBeginnerMode => _isBeginnerMode;

  // Workout initialization methods

  Future<void> startEmptyWorkout(String name) async {
    _currentWorkout = ActiveWorkout(
      name: name,
      startTime: DateTime.now(),
    );

    await _repository.saveActiveWorkout(_currentWorkout!);
    notifyListeners();
  }

  Future<void> startWorkoutFromSplit(WorkoutSplit split, WorkoutSession session) async {
    // Create a new workout based on the split and session
    _currentWorkout = ActiveWorkout(
      name: session.name,
      splitId: split.id,
      startTime: DateTime.now(),
    );

    // Initialize empty sets for each exercise in the session
    for (var exerciseRef in session.exercises) {
      _currentWorkout!.exerciseSets[exerciseRef.exerciseId] = [];
    }

    // If there are exercises, set the first one as current
    if (session.exercises.isNotEmpty) {
      _currentExerciseId = session.exercises.first.exerciseId;
    }

    await _repository.saveActiveWorkout(_currentWorkout!);
    notifyListeners();
  }

  Future<void> resumeWorkout(String workoutId) async {
    final workout = _repository.getActiveWorkout(workoutId);
    if (workout != null) {
      _currentWorkout = workout;

      // Set the first exercise with incomplete sets as current
      _setNextIncompleteExercise();

      notifyListeners();
    }
  }

  // Exercise navigation

  void selectExercise(String exerciseId) {
    if (_currentWorkout != null &&
        (_currentWorkout!.exerciseSets.containsKey(exerciseId) ||
         _currentExerciseId == null)) {
      _currentExerciseId = exerciseId;
      // Save the current workout when changing exercises
      _repository.saveActiveWorkout(_currentWorkout!);
      notifyListeners();
    }
  }

  void _setNextIncompleteExercise() {
    if (_currentWorkout == null) return;

    for (var entry in _currentWorkout!.exerciseSets.entries) {
      // Check if this exercise has any incomplete sets
      final hasIncompleteSets = entry.value.any((set) => !set.completed);
      if (hasIncompleteSets) {
        _currentExerciseId = entry.key;
        return;
      }
    }

    // If all sets are complete, just set the first exercise as current
    if (_currentWorkout!.exerciseSets.isNotEmpty) {
      _currentExerciseId = _currentWorkout!.exerciseSets.keys.first;
    }
  }

  // Set management methods

  Future<void> addSet(String exerciseId, ExerciseSet set) async {
    if (_currentWorkout == null) return;

    _currentWorkout!.addSet(exerciseId, set);
    await _repository.saveActiveWorkout(_currentWorkout!);
    notifyListeners();
  }

  Future<void> updateSet(String exerciseId, ExerciseSet updatedSet) async {
    if (_currentWorkout == null) return;

    final sets = _currentWorkout!.exerciseSets[exerciseId];
    if (sets != null) {
      final index = sets.indexWhere((set) => set.id == updatedSet.id);
      if (index != -1) {
        sets[index] = updatedSet;
        await _repository.saveActiveWorkout(_currentWorkout!);
        notifyListeners();
      }
    }
  }

  Future<void> removeSet(String exerciseId, String setId) async {
    if (_currentWorkout == null) return;

    _currentWorkout!.removeSet(exerciseId, setId);
    await _repository.saveActiveWorkout(_currentWorkout!);
    notifyListeners();
  }

  Future<void> markSetComplete(String exerciseId, String setId, bool completed) async {
    if (_currentWorkout == null) return;

    final sets = _currentWorkout!.exerciseSets[exerciseId];
    if (sets != null) {
      final index = sets.indexWhere((set) => set.id == setId);
      if (index != -1) {
        sets[index] = sets[index].copyWith(completed: completed);
        await _repository.saveActiveWorkout(_currentWorkout!);
        notifyListeners();
      }
    }
  }

  Future<void> duplicateLatestSet(String exerciseId) async {
    if (_currentWorkout == null) return;

    final sets = _currentWorkout!.exerciseSets[exerciseId];
    if (sets != null && sets.isNotEmpty) {
      // Get the latest set
      final latestSet = sets.last;

      // Create a duplicate with a new ID
      final newSet = ExerciseSet(
        weight: latestSet.weight,
        weightUnit: latestSet.weightUnit,
        reps: latestSet.reps,
        rpe: latestSet.rpe,
        isWarmup: latestSet.isWarmup,
        isDropSet: latestSet.isDropSet,
        notes: latestSet.notes,
        completed: false,
      );

      _currentWorkout!.addSet(exerciseId, newSet);
      await _repository.saveActiveWorkout(_currentWorkout!);
      notifyListeners();
    }
  }

  // Progressive Overload methods

  // Check if a set is a personal record (using 1RM calculation)
  bool isPersonalRecord(String exerciseId, ExerciseSet set) {
    return _repository.isPersonalRecord(exerciseId, set);
  }

  // Get all personal records for an exercise
  List<PersonalRecord> getPersonalRecordsForExercise(String exerciseId) {
    return _repository.getPersonalRecordsForExercise(exerciseId);
  }

  // Check if a set would be a new 1RM PR without saving it
  bool wouldBe1RMPR(String exerciseId, ExerciseSet set) {
    if (set.isWarmup || !set.completed) return false;
    
    final currentOneRM = calculate1RM(set);
    final currentBest = getBest1RM(exerciseId);
    
    if (currentBest == null) return true;
    if (currentBest.weightUnit != set.weightUnit) return false;
    
    const double threshold = 0.5;
    return currentOneRM.oneRepMax > (currentBest.value + threshold);
  }

  // Get current 1RM estimate for display purposes
  double? getCurrentEstimated1RM(String exerciseId) {
    final best = getBest1RM(exerciseId);
    return best?.value;
  }

  // Get performance trend for an exercise (for charts)
  List<Map<String, dynamic>> getPerformanceTrend(String exerciseId, {
    int limit = 10,
    bool byWeight = true,
  }) {
    return _repository.getPerformanceTrend(exerciseId, limit: limit, byWeight: byWeight);
  }

  // Get suggested progression for next set
  Map<String, dynamic> getSuggestedProgression(String exerciseId) {
    final settings = getProgressionSettings();

    return _repository.getSuggestedProgression(
      exerciseId,
      weightIncrementKg: settings['weightIncrementKg'],
      weightIncrementLb: settings['weightIncrementLb'],
      minRepsBeforeWeightIncrease: settings['minRepsBeforeWeightIncrease'],
      progressionStrategy: settings['progressionStrategy']
    );
  }

  // Check for plateau and get deload suggestions
  Map<String, dynamic> checkForPlateauAndSuggestDeload(String exerciseId) {
    final settings = getProgressionSettings();

    return _repository.checkForPlateauAndSuggestDeload(
      exerciseId,
      plateauThreshold: settings['plateauThreshold'],
      deloadPercentage: settings['deloadPercentage']
    );
  }

  // Apply progression suggestion to create a new set
  ExerciseSet createSetFromProgression(String exerciseId) {
    final suggestion = getSuggestedProgression(exerciseId);

    if (suggestion.isEmpty) {
      // No previous data, create a default set
      return ExerciseSet(
        weight: 0,
        reps: 0,
      );
    }

    return ExerciseSet(
      weight: suggestion['weight'],
      weightUnit: suggestion['weightUnit'],
      reps: suggestion['reps'],
      rpe: suggestion['rpe'],
    );
  }

  // Compare current set with previous performance
  Map<String, dynamic> compareWithPrevious(String exerciseId, ExerciseSet currentSet) {
    return _repository.compareWithPrevious(exerciseId, currentSet);
  }

  // Store user's progression settings
  Future<void> saveProgressionSettings(Map<String, dynamic> settings) async {
    _progressionSettings = settings;

    try {
      // Ensure the box is open
      if (!Hive.isBoxOpen(_settingsBoxName)) {
        await Hive.openBox(_settingsBoxName);
      }

      final box = Hive.box(_settingsBoxName);
      await box.put('progressionSettings', settings);

      print('Progression settings saved successfully: $settings');
    } catch (e) {
      print('Error saving progression settings: $e');
      // We still keep the settings in memory even if saving fails
    }

    notifyListeners();
  }

  // Also allow saving ProgressionSettings object directly
  Future<void> saveProgressionSettingsObject(ProgressionSettings settings) async {
    await saveProgressionSettings(settings.toMap());
  }

  // Get user's progression settings (with defaults)
  Map<String, dynamic> getProgressionSettings() {
    // Wait for initialization if needed
    if (!_isInitialized) {
      // In a real app, you might want to add some waiting logic here
      // For now, we'll just return defaults if not initialized
      return _getDefaultSettings();
    }

    // Return saved settings or defaults
    return _progressionSettings ?? _getDefaultSettings();
  }

  // Helper method to provide default settings
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'weightIncrementKg': 2.5,
      'weightIncrementLb': 5.0,
      'minRepsBeforeWeightIncrease': 8,
      'progressionStrategy': 'weight_first',
      'plateauThreshold': 3,
      'deloadPercentage': 0.10,
      'defaultRestTimeSeconds': 90,
    };
  }

  // Save the current workout to the repository
  Future<void> saveCurrentWorkout() async {
    if (_currentWorkout != null) {
      await _repository.saveActiveWorkout(_currentWorkout!);
      notifyListeners();
    }
  }

  // Rest timer methods

  void startRestTimer(int seconds) {
    _restTimerSeconds = seconds;
    _isRestTimerActive = true;
    notifyListeners();

    // Timer logic would be implemented here
    // For simplicity, we'll just use a Future.delayed approach
    _runTimer();
  }

  void pauseRestTimer() {
    _isRestTimerActive = false;
    notifyListeners();
  }

  void resumeRestTimer() {
    if (_restTimerSeconds > 0) {
      _isRestTimerActive = true;
      notifyListeners();
      _runTimer();
    }
  }

  void cancelRestTimer() {
    _restTimerSeconds = 0;
    _isRestTimerActive = false;
    notifyListeners();
  }

  Future<void> _runTimer() async {
    while (_isRestTimerActive && _restTimerSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRestTimerActive) {
        _restTimerSeconds--;
        notifyListeners();
      }
    }

    if (_restTimerSeconds == 0) {
      _isRestTimerActive = false;
      notifyListeners();
    }
  }

  // Workout completion

  Future<void> completeWorkout() async {
    if (_currentWorkout == null) return;

    _currentWorkout!.completeWorkout();
    await _repository.addToHistory(_currentWorkout!);

    // Reset current state
    _currentWorkout = null;
    _currentExerciseId = null;
    _restTimerSeconds = 0;
    _isRestTimerActive = false;

    notifyListeners();
  }

  Future<void> cancelWorkout() async {
    if (_currentWorkout == null) return;

    await _repository.deleteActiveWorkout(_currentWorkout!.id);

    // Reset current state
    _currentWorkout = null;
    _currentExerciseId = null;
    _restTimerSeconds = 0;
    _isRestTimerActive = false;

    notifyListeners();
  }

  // Exercise analysis

  List<ExerciseSet> getPreviousSets(String exerciseId) {
    return _repository.getPreviousSets(exerciseId);
  }

  ExerciseSet? getBestSet(String exerciseId) {
    return _repository.getBestSet(exerciseId);
  }

  // Get the best 1RM record for an exercise
  PersonalRecord? getBest1RM(String exerciseId) {
    return _repository.getBest1RM(exerciseId);
  }

  // Get the estimated 1RM for a set
  OneRepMaxResult calculate1RM(ExerciseSet set) {
    return OneRepMaxCalculator.calculate(
      weight: set.weight,
      reps: set.reps,
      weightUnit: set.weightUnit,
    );
  }

  // Workout history

  List<ActiveWorkout> getWorkoutHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? splitId,
    String? exerciseId,
  }) {
    return _repository.getWorkoutHistory(
      startDate: startDate,
      endDate: endDate,
      splitId: splitId,
      exerciseId: exerciseId,
    );
  }

  ActiveWorkout? getWorkoutById(String id) {
    return _repository.getWorkoutById(id);
  }
  
  // Settings management methods
  Future<void> setBeginnerMode(bool isBeginnerMode) async {
    _isBeginnerMode = isBeginnerMode;
    
    try {
      if (!Hive.isBoxOpen(_settingsBoxName)) {
        await Hive.openBox(_settingsBoxName);
      }
      
      final box = Hive.box(_settingsBoxName);
      await box.put('isBeginnerMode', isBeginnerMode);
      
      notifyListeners();
    } catch (e) {
      print('Error saving beginner mode setting: $e');
    }
  }
}
