import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/split_provider.dart';
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
                TabBar(
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
                  indicator: const BoxDecoration(), // Remove indicator
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'EXERCISES'),
                    Tab(text: 'SPLIT'),
                  ],
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExercisesTab(),
                _buildSplitTab(),
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
      body: Column(
        children: [
          // Filter dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showFiltersBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.royalVelvet,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Consumer<ExerciseProvider>(
                          builder: (context, exerciseProvider, child) {
                            return Text(
                              'All(${exerciseProvider.exercises.length})',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            );
                          },
                        ),
                      ],
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

                final exercises = exerciseProvider.exercises;

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
                          'No exercises found',
                          style: TextStyle(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseModal,
        backgroundColor: AppColors.velvetHighlight,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSplitTab() {
    return Consumer<SplitProvider>(
      builder: (context, splitProvider, child) {
        final splits = splitProvider.splits;

        if (splits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_view_day,
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
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: splits.length,
          itemBuilder: (context, index) {
            final split = splits[index];
            return _buildSplitCard(split);
          },
        );
      },
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
                  exercise.primaryMuscles.isNotEmpty 
                      ? exercise.primaryMuscles.first 
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
                    exercise.primaryMuscles.isNotEmpty 
                        ? exercise.primaryMuscles.first 
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.royalVelvet,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Split icon placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.velvetHighlight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_view_day,
              color: Colors.white.withOpacity(0.8),
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
                Text(
                  '${split.sessions.length} sessions',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Add button
          IconButton(
            onPressed: () => _openSplitDetails(split),
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

  Widget _getExerciseIcon(Exercise exercise) {
    // Get the appropriate muscle group icon
    String iconPath = 'assets/icons/muscle.png'; // Default
    
    if (exercise.primaryMuscles.isNotEmpty) {
      final primaryMuscle = exercise.primaryMuscles.first.toLowerCase();
      
      // Map to actual icon files that exist in assets/icons/
      switch (primaryMuscle) {
        // CHEST
        case 'chest':
        case 'pectorals':
        case 'pecs':
        case 'pectoral':
        case 'chest muscles':
        case 'pectoralis major':
        case 'upper pectoralis major':
        case 'lower pectoralis major':
          iconPath = 'assets/icons/chest.png';
          break;
        
        // BACK
        case 'back':
        case 'rear':
        case 'posterior':
        case 'back muscles':
        case 'erector spinae':
        case 'rhomboids':
        case 'middle trapezius':
          iconPath = 'assets/icons/back.png';
          break;
        
        // SHOULDERS
        case 'shoulders':
        case 'shoulder':
        case 'deltoids':
        case 'delts':
        case 'deltoid':
        case 'anterior deltoid':
        case 'posterior deltoid':
        case 'lateral deltoid':
        case 'middle deltoid':
        case 'supraspinatus':
          iconPath = 'assets/icons/shoulders.png';
          break;
        
        // ARMS/BICEPS
        case 'arms':
        case 'biceps':
        case 'bicep':
        case 'arm':
        case 'upper arms':
        case 'biceps brachii':
        case 'brachialis':
        case 'brachioradialis':
          iconPath = 'assets/icons/arms.png';
          break;
        
        // TRICEPS
        case 'triceps':
        case 'tricep':
        case 'triceps brachii':
        case 'back of arms':
          iconPath = 'assets/icons/triceps.png';
          break;
        
        // QUADS
        case 'legs':
        case 'quadriceps':
        case 'quads':
        case 'quad':
        case 'thighs':
        case 'front thigh':
        case 'quadriceps femoris':
        case 'upper legs':
          iconPath = 'assets/icons/quads.png';
          break;
        
        // HAMSTRINGS
        case 'hamstrings':
        case 'hamstring':
        case 'hams':
        case 'back thigh':
        case 'rear thigh':
        case 'biceps femoris':
          iconPath = 'assets/icons/hamstrings.png';
          break;
        
        // CALVES
        case 'calves':
        case 'calf':
        case 'lower legs':
        case 'gastrocnemius':
        case 'soleus':
        case 'calf muscles':
          iconPath = 'assets/icons/calves.png';
          break;
        
        // GLUTES
        case 'glutes':
        case 'glute':
        case 'gluteus':
        case 'gluteus maximus':
        case 'gluteus medius':
        case 'gluteus minimus':
        case 'butt':
        case 'buttocks':
        case 'hips':
          iconPath = 'assets/icons/glutes.png';
          break;
        
        // ABS
        case 'abs':
        case 'abdominals':
        case 'core':
        case 'stomach':
        case 'rectus abdominis':
        case 'lower rectus abdominis':
        case 'upper rectus abdominis':
        case 'six pack':
        case 'abdominal':
        case 'midsection':
        case 'obliques':
        case 'transverse abdominis':
        case 'hip flexors':
        case 'quadratus lumborum':
          iconPath = 'assets/icons/abs.png';
          break;
        
        // FOREARMS
        case 'forearms':
        case 'forearm':
        case 'lower arms':
        case 'wrists':
        case 'grip':
        case 'forearm flexors':
        case 'flexor carpi radialis':
        case 'flexor carpi ulnaris':
        case 'extensor carpi radialis':
        case 'extensor carpi ulnaris':
        case 'pronator teres':
        case 'pronator quadratus':
        case 'supinator':
          iconPath = 'assets/icons/forearms.png';
          break;
        
        // TRAPS
        case 'traps':
        case 'trapezius':
        case 'trap':
        case 'upper traps':
        case 'upper trapezius':
        case 'middle traps':
        case 'lower traps':
        case 'neck':
        case 'sternocleidomastoid':
        case 'scalenes':
        case 'splenius capitis':
        case 'deep cervical flexors':
          iconPath = 'assets/icons/traps.png';
          break;
        
        // LATS
        case 'lats':
        case 'latissimus dorsi':
        case 'lat':
        case 'side back':
        case 'wings':
        case 'lateral back':
          iconPath = 'assets/icons/lats.png';
          break;
        
        // LOWER BACK
        case 'lower back':
        case 'lumbar':
        case 'erector spinae':
        case 'spinal erectors':
        case 'back extensors':
        case 'lower spine':
          iconPath = 'assets/icons/lower_back.png';
          break;
        
        // CARDIO
        case 'cardio':
        case 'cardiovascular':
        case 'aerobic':
        case 'endurance':
        case 'conditioning':
        case 'heart':
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
          height: MediaQuery.of(context).size.height * 0.85,
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
              // Title
              const Text(
                'Add Exercise',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Name field
              const Text(
                'Name',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
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
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: Icon(
                      Icons.edit,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Body part field
              const Text(
                'Body part',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.royalVelvet,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedBodyPart ?? '',
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
              const SizedBox(height: 24),

              // Equipment field
              const Text(
                'Equipment',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.royalVelvet,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedEquipment ?? '',
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

              const Spacer(),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save logic here
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
                  const SizedBox(height: 12),
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
      'Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 
      'Abs', 'Glutes', 'Hamstrings', 'Quads', 'Calves'
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
}
