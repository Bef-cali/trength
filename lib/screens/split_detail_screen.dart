// lib/screens/split_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../providers/exercise_provider.dart';
import '../models/workout_split.dart';
import '../models/exercise_model.dart';
import '../theme/app_colors.dart';
import 'exercise_detail_screen.dart';

class SplitDetailScreen extends StatelessWidget {
  final WorkoutSplit split;

  const SplitDetailScreen({Key? key, required this.split}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: Text(
          split.name,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepVelvet,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSplit(context),
          ),
        ],
      ),
      body: Consumer2<SplitProvider, ExerciseProvider>(
        builder: (context, splitProvider, exerciseProvider, child) {
          // Get the current split from provider
          final currentSplit = splitProvider.getSplitById(split.id) ?? split;
          
          // Get all exercises directly from the split
          final allExercises = <Exercise>[];
          for (final exerciseRef in currentSplit.exercises) {
            final exercise = exerciseProvider.getExerciseById(exerciseRef.exerciseId);
            if (exercise != null) {
              allExercises.add(exercise);
            }
          }

          if (allExercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppColors.velvetMist.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Exercises',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.velvetLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add exercises to your split',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetLight.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showAddExerciseModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.velvetHighlight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Add Exercise',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Description
              if (currentSplit.description != null && currentSplit.description!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: AppColors.royalVelvet,
                  child: Text(
                    currentSplit.description!,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: AppColors.velvetLight,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Exercises List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = allExercises[index];
                    return _buildExerciseCard(context, exercise);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseModal(context),
        backgroundColor: AppColors.velvetPale,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    return Card(
      color: AppColors.royalVelvet,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _getExerciseIcon(exercise),
        title: Text(
          exercise.name,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              exercise.generalPrimaryMuscles.isNotEmpty 
                  ? exercise.generalPrimaryMuscles.join(', ')
                  : 'No target muscles',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            if (exercise.equipment != null) ...[
              const SizedBox(height: 2),
              Text(
                exercise.equipment!,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _confirmRemoveExercise(context, exercise),
        ),
        onTap: () => _openExerciseDetails(context, exercise),
      ),
    );
  }

  Widget _getExerciseIcon(Exercise exercise) {
    // Get the appropriate muscle group icon using general muscle groups
    String iconPath = 'assets/icons/muscle.png'; // Default
    
    if (exercise.generalPrimaryMuscles.isNotEmpty) {
      final primaryMuscle = exercise.generalPrimaryMuscles.first.toLowerCase();
      
      // Complete mapping for all general muscle group names
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
          return Icon(
            Icons.fitness_center,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          );
        },
      ),
    );
  }

  void _openExerciseDetails(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exerciseId: exercise.id),
      ),
    );
  }

  void _showAddExerciseModal(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final splitProvider = Provider.of<SplitProvider>(context, listen: false);
    
    // Clear any existing search when opening the modal
    exerciseProvider.setSearchQuery('');
    
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
              'Add Exercise to Split',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Search bar
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
              ),
              onChanged: (value) {
                exerciseProvider.setSearchQuery(value);
              },
            ),
            const SizedBox(height: 16),
            
            // Exercise list
            Expanded(
              child: Consumer2<ExerciseProvider, SplitProvider>(
                builder: (context, exerciseProvider, splitProvider, child) {
                  final filteredExercises = exerciseProvider.filteredExercises;
                  // Get the current split from provider to check for real-time updates
                  final currentSplit = splitProvider.getSplitById(split.id) ?? split;
                  
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
                      final isAlreadyInSplit = currentSplit.exercises.any(
                        (ref) => ref.exerciseId == exercise.id,
                      );
                      
                      return Card(
                        color: AppColors.royalVelvet,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _getExerciseIcon(exercise),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            exercise.generalPrimaryMuscles.isNotEmpty
                                ? exercise.generalPrimaryMuscles.join(', ')
                                : 'No target muscles',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          trailing: isAlreadyInSplit
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppColors.velvetHighlight,
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await splitProvider.addExerciseToSplit(
                                        split.id,
                                        exercise.id,
                                      );
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added "${exercise.name}" to split',
                                          ),
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
                                    minimumSize: const Size(60, 30),
                                  ),
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Close button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalVelvet,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
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
      ),
    );
  }

  void _confirmRemoveExercise(BuildContext context, Exercise exercise) {
    final splitProvider = Provider.of<SplitProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: const Text(
          'Remove Exercise',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Remove "${exercise.name}" from this split?',
          style: const TextStyle(
            fontFamily: 'Quicksand',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: AppColors.velvetLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await splitProvider.removeExerciseFromSplit(split.id, exercise.id);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Exercise "${exercise.name}" removed',
                      style: const TextStyle(fontFamily: 'Quicksand'),
                    ),
                    backgroundColor: AppColors.velvetHighlight,
                  ),
                );
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove exercise: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editSplit(BuildContext context) {
    final nameController = TextEditingController(text: split.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.deepVelvet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with delete icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Split',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name field
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Split name',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: AppColors.royalVelvet,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a split name'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      try {
                        final splitProvider = Provider.of<SplitProvider>(context, listen: false);
                        final updatedSplit = split.copyWith(name: name);
                        
                        await splitProvider.updateSplit(updatedSplit);
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Split "${name}" updated'),
                            backgroundColor: AppColors.velvetHighlight,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update: $e'),
                            backgroundColor: Colors.orange,
                          ),
                        );
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
                      'Update',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
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
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.royalVelvet,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Split',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${split.name}"?\n\nThis action cannot be undone.',
            style: const TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final splitProvider = Provider.of<SplitProvider>(context, listen: false);
                  await splitProvider.deleteSplit(split.id);
                  
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close split detail screen
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Split "${split.name}" deleted successfully'),
                      backgroundColor: AppColors.velvetHighlight,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete split: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
