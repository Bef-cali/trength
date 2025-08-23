import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/split_provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise_model.dart';
import '../models/workout_split.dart';
import '../theme/app_colors.dart';
import 'exercise_detail_screen.dart';
import 'split_detail_screen.dart';

class ExerciseBrowseScreen extends StatefulWidget {
  const ExerciseBrowseScreen({Key? key}) : super(key: key);

  @override
  _ExerciseBrowseScreenState createState() => _ExerciseBrowseScreenState();
}

class _ExerciseBrowseScreenState extends State<ExerciseBrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMuscleGroup;

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
                      Tab(text: 'SPLIT'),
                      Tab(text: 'EXERCISES'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Context-aware plus icon
                IconButton(
                  onPressed: () {
                    if (_tabController.index == 0) {
                      _showAddSplitModal();
                    } else {
                      _showAddExerciseModal();
                    }
                  },
                  icon: const Icon(
                    Icons.add,
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
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSplitTab(),
                _buildExercisesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab() {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      body: _selectedMuscleGroup == null 
        ? _buildMuscleGroupFilter()
        : _buildFilteredExerciseList(),
    );
  }

  Widget _buildFilteredExerciseList() {
    return Column(
      children: [
        // Header with selected muscle group and clear button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedMuscleGroup!.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMuscleGroup = null;
                  });
                  // Clear filter
                  final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
                  exerciseProvider.setMuscle(null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.velvetHighlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Exercise list
        Expanded(
          child: Consumer<ExerciseProvider>(
            builder: (context, exerciseProvider, child) {
              if (exerciseProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final exercises = exerciseProvider.filteredExercises;

              if (exercises.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: AppColors.velvetLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No exercises found for $_selectedMuscleGroup',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return _buildExerciseCard(exercise);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSplitTab() {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      body: Consumer<SplitProvider>(
        builder: (context, splitProvider, child) {
          final splits = splitProvider.splits;

          if (splits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppColors.velvetLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workout splits',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first split to get started',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: splits.length,
            itemBuilder: (context, index) {
              final split = splits[index];
              return _buildSplitCard(split);
            },
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Exercise icon - actual exercise logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.velvetLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _getExerciseIcon(exercise),
          ),
          const SizedBox(width: 16),
          // Exercise details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.generalPrimaryMuscles.isNotEmpty 
                      ? exercise.generalPrimaryMuscles.first 
                      : 'General',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.velvetHighlight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exercise.generalPrimaryMuscles.isNotEmpty 
                        ? exercise.generalPrimaryMuscles.first 
                        : 'General',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Add button
          IconButton(
            onPressed: () => _openExerciseDetails(exercise),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitCard(WorkoutSplit split) {
    // Get total exercises directly from split
    final totalExercises = split.exercises.length;

    return InkWell(
      onTap: () => _openSplitDetails(split),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.royalVelvet,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
        children: [
          // Split icon - workout related
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.velvetLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Split details
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
                Row(
                  children: [
                    Text(
                      '$totalExercises exercises',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                if (split.description != null && split.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.velvetHighlight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      split.description!,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Start workout button
          IconButton(
            onPressed: () => _startWorkoutFromSplit(split),
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _openExerciseDetails(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exerciseId: exercise.id),
      ),
    );
  }

  void _openSplitDetails(WorkoutSplit split) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitDetailScreen(split: split),
      ),
    );
  }

  void _startWorkoutFromSplit(WorkoutSplit split) {
    // Get all exercises directly from the split
    final allExercises = split.exercises.map((ref) => ref.exerciseId).toList();

    if (allExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This split has no exercises to start'),
          backgroundColor: AppColors.velvetHighlight,
        ),
      );
      return;
    }

    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    
    // Start a workout with all exercises from the split
    workoutProvider.startWorkoutFromSplitDirect(split.name, allExercises).then((_) {
      // Navigate to active workout screen
      Navigator.pushNamed(context, '/active-workout');
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start workout: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Widget _getExerciseIcon(Exercise exercise) {
    // Get the appropriate muscle group icon using general muscle groups
    String iconPath = 'assets/icons/muscle.png'; // Default
    
    if (exercise.generalPrimaryMuscles.isNotEmpty) {
      final primaryMuscle = exercise.generalPrimaryMuscles.first.toLowerCase();
      
      // Simple mapping using general muscle group names
      switch (primaryMuscle) {
        case 'chest':
          iconPath = 'assets/icons/chest.png';
          break;
        case 'back':
          iconPath = 'assets/icons/back.png';
          break;
        case 'shoulders':
          iconPath = 'assets/icons/shoulders.png';
          break;
        case 'arms':
          iconPath = 'assets/icons/arms.png';
          break;
        case 'triceps':
          iconPath = 'assets/icons/triceps.png';
          break;
        case 'legs':
          iconPath = 'assets/icons/quads.png';
          break;
        case 'hamstrings':
          iconPath = 'assets/icons/hamstrings.png';
          break;
        case 'calves':
          iconPath = 'assets/icons/calves.png';
          break;
        case 'glutes':
          iconPath = 'assets/icons/glutes.png';
          break;
        case 'abs':
          iconPath = 'assets/icons/abs.png';
          break;
        case 'forearms':
          iconPath = 'assets/icons/forearms.png';
          break;
        case 'traps':
          iconPath = 'assets/icons/traps.png';
          break;
        case 'lats':
          iconPath = 'assets/icons/lats.png';
          break;
        case 'neck':
          iconPath = 'assets/icons/traps.png'; // Using traps icon for neck
          break;
        case 'cardio':
          iconPath = 'assets/icons/cardio.png';
          break;
        default:
          iconPath = 'assets/icons/muscle.png';
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        iconPath,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to generic muscle icon if specific one fails
          return Image.asset(
            'assets/icons/muscle.png',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Final fallback to Material icon
              return Icon(
                Icons.fitness_center,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              );
            },
          );
        },
      ),
    );
  }

  void _showAddExerciseModal() {
    final nameController = TextEditingController();
    String? selectedBodyPart;
    String? selectedEquipment;

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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: AppColors.deepVelvet,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Add Exercise',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Name field
              const Text(
                'Name',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.royalVelvet,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Exercise name',
                    hintStyle: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.white.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: Icon(
                      Icons.edit,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Body part field
              const Text(
                'Body part',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.royalVelvet,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedBodyPart ?? 'Select body part',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: selectedBodyPart != null 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showBodyPartPicker(context, (selected) {
                      setState(() {
                        selectedBodyPart = selected;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.velvetHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Choose',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Equipment field
              const Text(
                'Equipment',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.royalVelvet,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedEquipment ?? 'Select equipment',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: selectedEquipment != null 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showEquipmentPicker(context, (selected) {
                      setState(() {
                        selectedEquipment = selected;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.velvetHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Choose',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate inputs
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter exercise name'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (selectedBodyPart == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select body part'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Create exercise with general muscle names
                        final exercise = Exercise(
                          name: nameController.text.trim(),
                          category: selectedBodyPart!,
                          primaryMuscles: [selectedBodyPart!], // Using general muscle name
                          secondaryMuscles: [],
                          equipment: selectedEquipment,
                          isCustom: true,
                        );

                        try {
                          final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
                          await exerciseProvider.addExercise(exercise);
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${exercise.name}" successfully'),
                              backgroundColor: AppColors.velvetHighlight,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add exercise: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.velvetHighlight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.royalVelvet,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBodyPartPicker(BuildContext context, Function(String) onSelected) {
    final bodyParts = [
      'Chest', 'Back', 'Shoulders', 'Arms', 'Triceps', 'Legs', 
      'Hamstrings', 'Calves', 'Glutes', 'Abs', 'Forearms', 
      'Traps', 'Lats', 'Neck', 'Cardio'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.deepVelvet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Body Part',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...bodyParts.map((bodyPart) => ListTile(
              title: Text(
                bodyPart,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.white,
                ),
              ),
              onTap: () {
                onSelected(bodyPart);
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showEquipmentPicker(BuildContext context, Function(String) onSelected) {
    final equipment = [
      'Barbell', 'Dumbbell', 'Cable', 'Machine', 'Bodyweight', 
      'Kettlebell', 'Resistance Band', 'Pull-up Bar'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.deepVelvet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Equipment',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...equipment.map((equip) => ListTile(
              title: Text(
                equip,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.white,
                ),
              ),
              onTap: () {
                onSelected(equip);
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.deepVelvet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Consumer<ExerciseProvider>(
          builder: (context, exerciseProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Category filter
                const Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: exerciseProvider.selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) {
                          exerciseProvider.setCategory(null);
                        }
                      },
                      backgroundColor: AppColors.royalVelvet,
                      selectedColor: AppColors.velvetPale.withOpacity(0.3),
                    ),
                    ...exerciseProvider.categories.map((category) =>
                      FilterChip(
                        label: Text(category),
                        selected: exerciseProvider.selectedCategory == category,
                        onSelected: (selected) {
                          exerciseProvider.setCategory(selected ? category : null);
                        },
                        backgroundColor: AppColors.royalVelvet,
                        selectedColor: AppColors.velvetPale.withOpacity(0.3),
                      ),
                    ).toList(),
                  ],
                ),
                const SizedBox(height: 16),

                // Equipment filter
                const Text(
                  'Equipment',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: exerciseProvider.selectedEquipment == null,
                      onSelected: (selected) {
                        if (selected) {
                          exerciseProvider.setEquipment(null);
                        }
                      },
                      backgroundColor: AppColors.royalVelvet,
                      selectedColor: AppColors.velvetPale.withOpacity(0.3),
                    ),
                    ...exerciseProvider.equipmentTypes.map((equipment) =>
                      FilterChip(
                        label: Text(equipment),
                        selected: exerciseProvider.selectedEquipment == equipment,
                        onSelected: (selected) {
                          exerciseProvider.setEquipment(selected ? equipment : null);
                        },
                        backgroundColor: AppColors.royalVelvet,
                        selectedColor: AppColors.velvetPale.withOpacity(0.3),
                      ),
                    ).toList(),
                  ],
                ),
                const SizedBox(height: 16),

                // Muscle filter
                const Text(
                  'Muscle Group',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: exerciseProvider.selectedMuscle == null,
                      onSelected: (selected) {
                        if (selected) {
                          exerciseProvider.setMuscle(null);
                        }
                      },
                      backgroundColor: AppColors.royalVelvet,
                      selectedColor: AppColors.velvetPale.withOpacity(0.3),
                    ),
                    ...exerciseProvider.muscleGroups.map((muscle) =>
                      FilterChip(
                        label: Text(muscle),
                        selected: exerciseProvider.selectedMuscle == muscle,
                        onSelected: (selected) {
                          exerciseProvider.setMuscle(selected ? muscle : null);
                        },
                        backgroundColor: AppColors.royalVelvet,
                        selectedColor: AppColors.velvetPale.withOpacity(0.3),
                      ),
                    ).toList(),
                  ],
                ),
                const SizedBox(height: 24),

                // Clear all button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      exerciseProvider.clearFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.velvetHighlight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Clear All Filters',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddSplitModal() {
    final nameController = TextEditingController();
    final selectedExercises = <String>{};
    
    // Clear any existing filters for a fresh start
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    exerciseProvider.setSearchQuery('');
    exerciseProvider.setMuscle(null);

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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.deepVelvet,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Split Name
              Row(
                children: [
                  const Text(
                    'Create Split',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${selectedExercises.length} exercises',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetHighlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Split name field - compact
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter split name...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.velvetHighlight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Exercise search
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.velvetHighlight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  Provider.of<ExerciseProvider>(context, listen: false).setSearchQuery(value);
                },
              ),
              const SizedBox(height: 16),

              // Horizontal muscle group filter
              SizedBox(
                height: 40,
                child: Consumer<ExerciseProvider>(
                  builder: (context, exerciseProvider, child) {
                    final muscleGroups = ['All', ...exerciseProvider.muscleGroups];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: muscleGroups.length,
                      itemBuilder: (context, index) {
                        final muscle = muscleGroups[index];
                        final isSelected = (muscle == 'All' && exerciseProvider.selectedMuscle == null) ||
                                         muscle == exerciseProvider.selectedMuscle;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              muscle,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              exerciseProvider.setMuscle(muscle == 'All' ? null : muscle);
                            },
                            backgroundColor: AppColors.royalVelvet,
                            selectedColor: AppColors.velvetHighlight,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Exercise list
              Expanded(
                child: Consumer<ExerciseProvider>(
                  builder: (context, exerciseProvider, child) {
                    final filteredExercises = exerciseProvider.filteredExercises;
                    
                    if (filteredExercises.isEmpty) {
                      return const Center(
                        child: Text(
                          'No exercises found',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        final isSelected = selectedExercises.contains(exercise.id);
                        
                        return Card(
                          color: isSelected 
                              ? AppColors.velvetHighlight.withOpacity(0.3) 
                              : AppColors.royalVelvet,
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: _getExerciseIcon(exercise),
                            title: Text(
                              exercise.name,
                              style: const TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              exercise.generalPrimaryMuscles.isNotEmpty
                                  ? exercise.generalPrimaryMuscles.join(', ')
                                  : 'No target muscles',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.velvetHighlight, size: 20)
                                : Icon(Icons.add_circle_outline, color: Colors.white.withOpacity(0.5), size: 20),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedExercises.remove(exercise.id);
                                } else {
                                  selectedExercises.add(exercise.id);
                                }
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Action buttons - compact
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isNotEmpty) {
                          final splitProvider = Provider.of<SplitProvider>(context, listen: false);
                          
                          try {
                            // Create the split first
                            final newSplit = await splitProvider.createSplit(
                              name: nameController.text.trim(),
                            );
                            
                            // Add selected exercises to the split
                            for (final exerciseId in selectedExercises) {
                              await splitProvider.addExerciseToSplit(newSplit.id, exerciseId);
                            }
                            
                            Navigator.pop(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Split "${newSplit.name}" created with ${selectedExercises.length} exercises'),
                                backgroundColor: AppColors.velvetHighlight,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create split: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.velvetHighlight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create Split',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGroupFilter() {
    final muscleGroups = [
      {'name': 'Abs', 'icon': 'assets/icons/abs.png'},
      {'name': 'Chest', 'icon': 'assets/icons/chest.png'},
      {'name': 'Back', 'icon': 'assets/icons/back.png'},
      {'name': 'Arms', 'icon': 'assets/icons/arms.png'},
      {'name': 'Legs', 'icon': 'assets/icons/legs.png'},
      {'name': 'Shoulders', 'icon': 'assets/icons/shoulders.png'},
      {'name': 'Glutes', 'icon': 'assets/icons/glutes.png'},
      {'name': 'Calves', 'icon': 'assets/icons/calves.png'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FOCUS AREA',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: muscleGroups.length,
              itemBuilder: (context, index) {
                final muscleGroup = muscleGroups[index];
                return _buildMuscleGroupCard(
                  muscleGroup['name']!,
                  muscleGroup['icon']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupCard(String name, String iconPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMuscleGroup = name;
        });
        // Apply filter to exercise provider
        final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
        exerciseProvider.setMuscle(name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.royalVelvet,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  iconPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  color: Colors.white.withOpacity(0.8),
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.fitness_center,
                      color: Colors.white.withOpacity(0.7),
                      size: 32,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
