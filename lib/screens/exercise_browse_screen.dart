import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../widgets/exercise_card.dart';
import '../providers/exercise_provider.dart';
import '../models/exercise_model.dart';
import '../theme/app_colors.dart';
import 'exercise_detail_screen.dart';
import 'add_exercise_screen.dart';

class ExerciseBrowseScreen extends StatefulWidget {
  const ExerciseBrowseScreen({Key? key}) : super(key: key);

  @override
  _ExerciseBrowseScreenState createState() => _ExerciseBrowseScreenState();
}

class _ExerciseBrowseScreenState extends State<ExerciseBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Toggle Filters',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExerciseScreen(),
                ),
              );
            },
            tooltip: 'Add Custom Exercise',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Exercises',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ExerciseProvider>(context, listen: false)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                Provider.of<ExerciseProvider>(context, listen: false)
                    .setSearchQuery(value);
              },
            ),
          ),

          // Filters section
          if (_showFilters) _buildFiltersSection(),

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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: AppColors.velvetLight.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises found',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        if (exerciseProvider.searchQuery.isNotEmpty ||
                            exerciseProvider.selectedCategory != null ||
                            exerciseProvider.selectedEquipment != null ||
                            exerciseProvider.selectedMuscle != null)
                          TextButton.icon(
                            icon: const Icon(Icons.filter_list_off),
                            label: const Text('Clear Filters'),
                            onPressed: () {
                              _searchController.clear();
                              exerciseProvider.clearFilters();
                            },
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ExerciseCard(
                      exercise: exercise,
                      onTap: () => _openExerciseDetails(exercise),
                      onAddToWorkout: () {
                        // This will be implemented in Phase 3
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${exercise.name} to workout'),
                            backgroundColor: AppColors.velvetPale,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExerciseScreen(),
            ),
          );
        },
        backgroundColor: AppColors.velvetPale,
        child: const Icon(Icons.add),
        tooltip: 'Add Custom Exercise',
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Consumer<ExerciseProvider>(
      builder: (context, exerciseProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.royalVelvet.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.velvetMist,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    onPressed: () {
                      _searchController.clear();
                      exerciseProvider.clearFilters();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'Category:',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: AppColors.velvetLight,
                        ),
                      ),
                    ),
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
                          backgroundColor: AppColors.deepVelvet,
                          selectedColor: AppColors.velvetPale.withOpacity(0.3),
                        ),
                        ...exerciseProvider.categories.map((category) =>
                          FilterChip(
                            label: Text(category),
                            selected: exerciseProvider.selectedCategory == category,
                            onSelected: (selected) {
                              exerciseProvider.setCategory(selected ? category : null);
                            },
                            backgroundColor: AppColors.deepVelvet,
                            selectedColor: AppColors.velvetPale.withOpacity(0.3),
                          ),
                        ).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Equipment filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'Equipment:',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: AppColors.velvetLight,
                        ),
                      ),
                    ),
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
                          backgroundColor: AppColors.deepVelvet,
                          selectedColor: AppColors.velvetPale.withOpacity(0.3),
                        ),
                        ...exerciseProvider.equipmentTypes.map((equipment) =>
                          FilterChip(
                            label: Text(equipment),
                            selected: exerciseProvider.selectedEquipment == equipment,
                            onSelected: (selected) {
                              exerciseProvider.setEquipment(selected ? equipment : null);
                            },
                            backgroundColor: AppColors.deepVelvet,
                            selectedColor: AppColors.velvetPale.withOpacity(0.3),
                          ),
                        ).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Muscle group filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'Muscle:',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: AppColors.velvetLight,
                        ),
                      ),
                    ),
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
                          backgroundColor: AppColors.deepVelvet,
                          selectedColor: AppColors.velvetPale.withOpacity(0.3),
                        ),
                        ...exerciseProvider.muscleGroups.map((muscle) =>
                          FilterChip(
                            label: Text(muscle),
                            selected: exerciseProvider.selectedMuscle == muscle,
                            onSelected: (selected) {
                              exerciseProvider.setMuscle(selected ? muscle : null);
                            },
                            backgroundColor: AppColors.deepVelvet,
                            selectedColor: AppColors.velvetPale.withOpacity(0.3),
                          ),
                        ).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
}
