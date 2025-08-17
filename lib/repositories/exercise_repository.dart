import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  static const String _boxName = 'exercises';
  late Box<Exercise> _exerciseBox;

  // Initialize Hive and open the exercise box
  Future<void> initialize() async {
    // Register the Exercise adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExerciseAdapter());
    }

    // Open the box
    _exerciseBox = await Hive.openBox<Exercise>(_boxName);

    // If this is the first run, populate with default exercises
    if (_exerciseBox.isEmpty) {
      await _populateDefaultExercises();
    }
  }

  // Load exercises from the JSON asset file
  Future<void> _populateDefaultExercises() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert JSON to Exercise objects and add to Hive
      final exercises = jsonList.map((json) => Exercise.fromJson(json)).toList();

      // Add all exercises to the box in a single transaction
      await _exerciseBox.addAll(exercises);

      print('Default exercises loaded: ${exercises.length}');
    } catch (e) {
      print('Error loading default exercises: $e');
    }
  }

  // Get all exercises
  List<Exercise> getAllExercises() {
    return _exerciseBox.values.toList();
  }

  // Get exercises by category
  List<Exercise> getExercisesByCategory(String category) {
    return _exerciseBox.values
        .where((exercise) => exercise.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Get arm-related exercises (including Biceps, Triceps, Forearms)
  List<Exercise> getArmExercises() {
    return _exerciseBox.values
        .where((exercise) =>
            exercise.category.toLowerCase() == 'biceps' ||
            exercise.category.toLowerCase() == 'triceps' ||
            exercise.category.toLowerCase() == 'forearms' ||
            exercise.category.toLowerCase() == 'arms')
        .toList();
  }

  // Get biceps exercises
  List<Exercise> getBicepsExercises() {
    return _exerciseBox.values
        .where((exercise) => exercise.category.toLowerCase() == 'biceps')
        .toList();
  }

  // Get triceps exercises
  List<Exercise> getTricepsExercises() {
    return _exerciseBox.values
        .where((exercise) => exercise.category.toLowerCase() == 'triceps')
        .toList();
  }

  // Get forearm exercises
  List<Exercise> getForearmExercises() {
    return _exerciseBox.values
        .where((exercise) => exercise.category.toLowerCase() == 'forearms')
        .toList();
  }

  // Get neck exercises
  List<Exercise> getNeckExercises() {
    return _exerciseBox.values
        .where((exercise) => exercise.category.toLowerCase() == 'neck')
        .toList();
  }

  // Get exercises by primary muscle
  List<Exercise> getExercisesByMuscle(String muscle) {
    return _exerciseBox.values
        .where((exercise) =>
            exercise.primaryMuscles.any((m) => m.toLowerCase() == muscle.toLowerCase()) ||
            exercise.secondaryMuscles.any((m) => m.toLowerCase() == muscle.toLowerCase()))
        .toList();
  }

  // Get exercises by equipment
  List<Exercise> getExercisesByEquipment(String equipment) {
    return _exerciseBox.values
        .where((exercise) =>
            exercise.equipment != null &&
            exercise.equipment!.toLowerCase() == equipment.toLowerCase())
        .toList();
  }

  // Get exercises by search term (name search)
  List<Exercise> searchExercises(String term) {
    return _exerciseBox.values
        .where((exercise) =>
            exercise.name.toLowerCase().contains(term.toLowerCase()))
        .toList();
  }

  // Get a single exercise by ID
  Exercise? getExerciseById(String id) {
    final exercises = _exerciseBox.values.where((exercise) => exercise.id == id);
    return exercises.isNotEmpty ? exercises.first : null;
  }

  // Add a new exercise
  Future<void> addExercise(Exercise exercise) async {
    await _exerciseBox.put(exercise.id, exercise);
  }

  // Update an existing exercise
  Future<void> updateExercise(Exercise exercise) async {
    await _exerciseBox.put(exercise.id, exercise);
  }

  // Delete an exercise
  Future<void> deleteExercise(String id) async {
    await _exerciseBox.delete(id);
  }

  // Get all custom exercises
  List<Exercise> getCustomExercises({String? userId}) {
    return _exerciseBox.values
        .where((exercise) =>
            exercise.isCustom &&
            (userId == null || exercise.userId == userId))
        .toList();
  }

  // Get all available categories
  List<String> getAllCategories() {
    return _exerciseBox.values
        .map((exercise) => exercise.category)
        .toSet()
        .toList();
  }

  // Get the standard categories (ordered by preference)
  List<String> getStandardCategories() {
    final Set<String> availableCategories = _exerciseBox.values
        .map((exercise) => exercise.category)
        .toSet();

    // Standard category order with the new categories included
    final List<String> standardOrder = [
      'Chest',
      'Back',
      'Legs',
      'Shoulders',
      'Biceps',
      'Triceps',
      'Forearms',
      'Neck',
      'Core',
      'Abs',
      'Cardio'
    ];

    // Filter to only include categories that actually exist in the database
    final List<String> result = standardOrder
        .where((category) => availableCategories.contains(category))
        .toList();

    // Add any categories not in the standard list at the end
    availableCategories
        .where((category) => !standardOrder.contains(category))
        .forEach((category) => result.add(category));

    return result;
  }

  // Get all available equipment types
  List<String> getAllEquipmentTypes() {
    return _exerciseBox.values
        .where((exercise) => exercise.equipment != null)
        .map((exercise) => exercise.equipment!)
        .toSet()
        .toList();
  }

  // Get all available muscle groups
  List<String> getAllMuscleGroups() {
    Set<String> muscles = {};

    for (var exercise in _exerciseBox.values) {
      muscles.addAll(exercise.primaryMuscles);
      muscles.addAll(exercise.secondaryMuscles);
    }

    return muscles.toList();
  }

  // Get all available muscle groups (general names)
  List<String> getAllGeneralMuscleGroups() {
    Set<String> muscles = {};

    for (var exercise in _exerciseBox.values) {
      muscles.addAll(exercise.generalPrimaryMuscles);
      muscles.addAll(exercise.generalSecondaryMuscles);
    }

    return muscles.toList()..sort();
  }

  // Get exercises by general muscle group
  List<Exercise> getExercisesByGeneralMuscle(String generalMuscle) {
    return _exerciseBox.values
        .where((exercise) =>
            exercise.generalPrimaryMuscles.any((m) => m.toLowerCase() == generalMuscle.toLowerCase()) ||
            exercise.generalSecondaryMuscles.any((m) => m.toLowerCase() == generalMuscle.toLowerCase()))
        .toList();
  }

  // Recategorize arms exercises - can be used when updating to the new category system
  Future<void> recategorizeArmsExercises() async {
    final armsExercises = _exerciseBox.values
        .where((exercise) => exercise.category.toLowerCase() == 'arms')
        .toList();

    for (var exercise in armsExercises) {
      String newCategory = 'Arms'; // Default if can't determine

      // Check primary muscles to determine the appropriate category
      final primaryMusclesStr = exercise.primaryMuscles.join(' ').toLowerCase();

      if (primaryMusclesStr.contains('biceps') ||
          primaryMusclesStr.contains('brachialis') ||
          primaryMusclesStr.contains('brachioradialis')) {
        newCategory = 'Biceps';
      } else if (primaryMusclesStr.contains('triceps')) {
        newCategory = 'Triceps';
      } else if (primaryMusclesStr.contains('forearm') ||
                primaryMusclesStr.contains('flexor') ||
                primaryMusclesStr.contains('extensor') ||
                primaryMusclesStr.contains('carpi')) {
        newCategory = 'Forearms';
      }

      // Update the exercise with the new category if changed
      if (newCategory != exercise.category) {
        final updatedExercise = exercise.copyWith(category: newCategory);
        await updateExercise(updatedExercise);
      }
    }
  }

  // Recategorize neck exercises - move them from Shoulders to Neck
  Future<void> recategorizeNeckExercises() async {
    final shouldersExercises = _exerciseBox.values
        .where((exercise) => exercise.category.toLowerCase() == 'shoulders')
        .toList();

    for (var exercise in shouldersExercises) {
      final nameLower = exercise.name.toLowerCase();
      final primaryMusclesStr = exercise.primaryMuscles.join(' ').toLowerCase();

      // Check if this is a neck exercise
      bool isNeckExercise = nameLower.contains('neck') ||
                          primaryMusclesStr.contains('sternocleidomastoid') ||
                          primaryMusclesStr.contains('scalene') ||
                          primaryMusclesStr.contains('cervical');

      // Move to Neck category if it's a neck exercise
      if (isNeckExercise) {
        final updatedExercise = exercise.copyWith(category: 'Neck');
        await updateExercise(updatedExercise);
      }
    }
  }

  // Close the box when done
  Future<void> close() async {
    await _exerciseBox.close();
  }
}
