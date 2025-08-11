import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';
import '../repositories/exercise_repository.dart';

class ExerciseProvider with ChangeNotifier {
  final ExerciseRepository _repository;

  // All exercises
  List<Exercise> _exercises = [];

  // Filtered exercises (based on search/filter)
  List<Exercise> _filteredExercises = [];

  // Categories, equipment, and muscles for filtering
  List<String> _categories = [];
  List<String> _equipmentTypes = [];
  List<String> _muscleGroups = [];

  // Current filters
  String? _selectedCategory;
  String? _selectedEquipment;
  String? _selectedMuscle;
  String _searchQuery = '';

  // Loading state
  bool _isLoading = false;

  // Constructor
  ExerciseProvider(this._repository) {
    _initialize();
  }

  // Initialize the provider by loading data from repository
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    // Load all exercises
    _exercises = _repository.getAllExercises();
    _filteredExercises = List.from(_exercises);

    // Load filter options - using the ordered list for categories
    _categories = _repository.getStandardCategories();
    _equipmentTypes = _repository.getAllEquipmentTypes();
    _muscleGroups = _repository.getAllMuscleGroups();

    _isLoading = false;
    notifyListeners();
  }

  // Getters
  List<Exercise> get exercises => _exercises;
  List<Exercise> get filteredExercises => _filteredExercises;
  List<String> get categories => _categories;
  List<String> get equipmentTypes => _equipmentTypes;
  List<String> get muscleGroups => _muscleGroups;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  String? get selectedEquipment => _selectedEquipment;
  String? get selectedMuscle => _selectedMuscle;
  String get searchQuery => _searchQuery;

  // Get exercises by body part category group
  List<Exercise> getChestExercises() => _repository.getExercisesByCategory('Chest');
  List<Exercise> getBackExercises() => _repository.getExercisesByCategory('Back');
  List<Exercise> getLegsExercises() => _repository.getExercisesByCategory('Legs');
  List<Exercise> getShouldersExercises() => _repository.getExercisesByCategory('Shoulders');

  // Get exercises from the new categories
  List<Exercise> getBicepsExercises() => _repository.getBicepsExercises();
  List<Exercise> getTricepsExercises() => _repository.getTricepsExercises();
  List<Exercise> getForearmExercises() => _repository.getForearmExercises();
  List<Exercise> getNeckExercises() => _repository.getNeckExercises();

  // Get all arm-related exercises
  List<Exercise> getArmExercises() => _repository.getArmExercises();

  // Get core exercises
  List<Exercise> getCoreExercises() {
    return _repository.getExercisesByCategory('Core')
        .followedBy(_repository.getExercisesByCategory('Abs'))
        .toList();
  }

  // Get cardio exercises
  List<Exercise> getCardioExercises() => _repository.getExercisesByCategory('Cardio');

  // Refresh data from repository
  Future<void> refreshExercises() async {
    _isLoading = true;
    notifyListeners();

    _exercises = _repository.getAllExercises();

    // Refresh the categories to ensure new ones are included
    _categories = _repository.getStandardCategories();
    _equipmentTypes = _repository.getAllEquipmentTypes();
    _muscleGroups = _repository.getAllMuscleGroups();

    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // Apply all current filters
  void _applyFilters() {
    _filteredExercises = List.from(_exercises);

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredExercises = _filteredExercises
          .where((exercise) => exercise.category == _selectedCategory)
          .toList();
    }

    // Apply equipment filter
    if (_selectedEquipment != null && _selectedEquipment!.isNotEmpty) {
      _filteredExercises = _filteredExercises
          .where((exercise) =>
              exercise.equipment != null &&
              exercise.equipment == _selectedEquipment)
          .toList();
    }

    // Apply muscle filter
    if (_selectedMuscle != null && _selectedMuscle!.isNotEmpty) {
      _filteredExercises = _filteredExercises
          .where((exercise) =>
              exercise.primaryMuscles.contains(_selectedMuscle) ||
              exercise.secondaryMuscles.contains(_selectedMuscle))
          .toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      _filteredExercises = _filteredExercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  // Set category filter
  void setCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Set equipment filter
  void setEquipment(String? equipment) {
    _selectedEquipment = equipment;
    _applyFilters();
  }

  // Set muscle filter
  void setMuscle(String? muscle) {
    _selectedMuscle = muscle;
    _applyFilters();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedEquipment = null;
    _selectedMuscle = null;
    _searchQuery = '';
    _filteredExercises = List.from(_exercises);
    notifyListeners();
  }

  // Get a single exercise by ID
  Exercise? getExerciseById(String id) {
    return _repository.getExerciseById(id);
  }

  // Add a new exercise
  Future<void> addExercise(Exercise exercise) async {
    await _repository.addExercise(exercise);
    await refreshExercises();

    // Update filter options if needed
    if (!_categories.contains(exercise.category)) {
      _categories.add(exercise.category);
    }

    if (exercise.equipment != null && !_equipmentTypes.contains(exercise.equipment)) {
      _equipmentTypes.add(exercise.equipment!);
    }

    for (var muscle in exercise.primaryMuscles) {
      if (!_muscleGroups.contains(muscle)) {
        _muscleGroups.add(muscle);
      }
    }

    for (var muscle in exercise.secondaryMuscles) {
      if (!_muscleGroups.contains(muscle)) {
        _muscleGroups.add(muscle);
      }
    }

    notifyListeners();
  }

  // Update an existing exercise
  Future<void> updateExercise(Exercise exercise) async {
    await _repository.updateExercise(exercise);
    await refreshExercises();
  }

  // Delete an exercise
  Future<void> deleteExercise(String id) async {
    await _repository.deleteExercise(id);
    await refreshExercises();
  }

  // Get all custom exercises
  List<Exercise> getCustomExercises({String? userId}) {
    return _repository.getCustomExercises(userId: userId);
  }

  // Recategorize existing exercises based on the new category system
  Future<void> recategorizeExercises() async {
    _isLoading = true;
    notifyListeners();

    // Recategorize Arms exercises to Biceps, Triceps, Forearms
    await _repository.recategorizeArmsExercises();

    // Recategorize neck exercises from Shoulders to Neck
    await _repository.recategorizeNeckExercises();

    // Refresh everything after recategorizing
    await refreshExercises();

    _isLoading = false;
    notifyListeners();
  }
}
