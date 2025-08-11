// lib/screens/exercise_selector_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../providers/exercise_provider.dart';
import '../theme/app_colors.dart';

class ExerciseSelectorScreen extends StatefulWidget {
  const ExerciseSelectorScreen({Key? key}) : super(key: key);

  @override
  _ExerciseSelectorScreenState createState() => _ExerciseSelectorScreenState();
}

class _ExerciseSelectorScreenState extends State<ExerciseSelectorScreen> {
  @override
  void initState() {
    super.initState();
    // Clear filters when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false).clearFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: const Text(
          'Select Exercise',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepVelvet,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.royalVelvet,
            child: Column(
              children: [
                // Search field
                Consumer<ExerciseProvider>(
                  builder: (context, exerciseProvider, _) {
                    return TextField(
                      onChanged: (value) {
                        exerciseProvider.setSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        hintStyle: TextStyle(
                          color: AppColors.velvetLight.withOpacity(0.7),
                          fontFamily: 'Quicksand',
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.velvetLight,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.deepVelvet,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Quicksand',
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Filter chips
                Consumer<ExerciseProvider>(
                  builder: (context, exerciseProvider, child) {
                    final categories = exerciseProvider.categories;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // All category chip
                          FilterChip(
                            label: const Text('All'),
                            selected: exerciseProvider.selectedCategory == null,
                            onSelected: (selected) {
                              exerciseProvider.setCategory(selected ? null : null);
                            },
                            backgroundColor: AppColors.deepVelvet,
                            selectedColor: AppColors.velvetPale,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: exerciseProvider.selectedCategory == null
                                  ? Colors.white
                                  : AppColors.velvetLight,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Category chips
                          ...categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: exerciseProvider.selectedCategory == category,
                                onSelected: (selected) {
                                  exerciseProvider.setCategory(selected ? category : null);
                                },
                                backgroundColor: AppColors.deepVelvet,
                                selectedColor: AppColors.velvetPale,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: exerciseProvider.selectedCategory == category
                                      ? Colors.white
                                      : AppColors.velvetLight,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Exercise list
          Expanded(
            child: Consumer<ExerciseProvider>(
              builder: (context, exerciseProvider, child) {
                final exercises = exerciseProvider.filteredExercises;

                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.velvetMist.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises found',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.velvetLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppColors.royalVelvet,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, exercise.id);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Exercise category icon
                              _buildCategoryIcon(exercise.category),
                              const SizedBox(width: 16),

                              // Exercise details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Exercise name
                                    Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),

                                    // Category
                                    Text(
                                      exercise.category,
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 14,
                                        color: AppColors.velvetPale,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Primary muscles
                                    if (exercise.primaryMuscles.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        children: exercise.primaryMuscles.map((muscle) =>
                                          _buildChip(muscle, isPrimary: true)
                                        ).toList(),
                                      ),

                                    // Equipment if available
                                    if (exercise.equipment != null && exercise.equipment!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              MaterialCommunityIcons.dumbbell,
                                              size: 14,
                                              color: AppColors.velvetLight,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              exercise.equipment!,
                                              style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontSize: 12,
                                                color: AppColors.velvetLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Add icon
                              Icon(
                                Icons.add_circle_outline,
                                color: AppColors.velvetPale,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    String iconPath;

    // Assign icon path based on category
    switch (category.toLowerCase()) {
      case 'chest':
        iconPath = 'assets/icons/chest.png';
        break;
      case 'back':
        iconPath = 'assets/icons/back.png';
        break;
      case 'legs':
        iconPath = 'assets/icons/legs.png';
        break;
      case 'shoulders':
        iconPath = 'assets/icons/shoulders.png';
        break;
      case 'arms':
        iconPath = 'assets/icons/arms.png';
        break;
      case 'biceps':
        iconPath = 'assets/icons/arms.png';
        break;
      case 'triceps':
        iconPath = 'assets/icons/triceps.png';
        break;
      case 'forearms':
        iconPath = 'assets/icons/forearms.png';
        break;
      case 'neck':
        iconPath = 'assets/icons/neck.png';
        break;
      case 'core':
      case 'abs':
      case 'abdominals':
        iconPath = 'assets/icons/abs.png';
        break;
      case 'cardio':
        iconPath = 'assets/icons/cardio.png';
        break;
      default:
        iconPath = 'assets/icons/dumbbell.png';
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.velvetHighlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(
          iconPath,
          width: 36,
          height: 36,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to an icon if image loading fails
            return Icon(
              MaterialCommunityIcons.dumbbell,
              color: Colors.white,
              size: 28,
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.velvetPale.withOpacity(0.3) : AppColors.velvetHighlight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 12,
          color: isPrimary ? AppColors.velvetMist : AppColors.velvetLight,
        ),
      ),
    );
  }
}
