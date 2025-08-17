import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../providers/exercise_provider.dart';
import '../models/exercise_model.dart';
import '../theme/app_colors.dart';
import 'add_exercise_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetailScreen({
    Key? key,
    required this.exerciseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, exerciseProvider, child) {
        final exercise = exerciseProvider.getExerciseById(exerciseId);

        if (exercise == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Exercise Details'),
            ),
            body: const Center(
              child: Text('Exercise not found'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.deepVelvet,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, exercise),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and equipment
                      Row(
                        children: [
                          _buildInfoChip(
                            exercise.category,
                            Icons.category,
                            AppColors.velvetPale,
                          ),
                          if (exercise.equipment != null && exercise.equipment!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: _buildInfoChip(
                                exercise.equipment!,
                                MaterialCommunityIcons.dumbbell,
                                AppColors.velvetLight,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (exercise.description != null && exercise.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exercise.description!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Muscle groups
                      Text(
                        'Muscle Groups',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildMuscleSection(context, exercise),
                      const SizedBox(height: 24),

                      // Custom exercise info
                      if (exercise.isCustom)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: AppColors.velvetMist,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Custom Exercise',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: AppColors.velvetMist,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Created: ${_formatDate(exercise.createdAt)}',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Actions
                      _buildActionButtons(context, exercise, exerciseProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Exercise exercise) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          exercise.name,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.velvetPale,
                AppColors.velvetHighlight,
                AppColors.royalVelvet,
              ],
            ),
          ),
          child: Center(
            child: _getCategoryImage(exercise.category),
          ),
        ),
      ),
      actions: [
        if (exercise.isCustom)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editExercise(context, exercise),
            tooltip: 'Edit Exercise',
          ),
        IconButton(
          icon: const Icon(Icons.fitness_center),
          onPressed: () {
            // This will be implemented in Phase 3
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${exercise.name} to workout'),
                backgroundColor: AppColors.velvetPale,
              ),
            );
          },
          tooltip: 'Add to Workout',
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleSection(BuildContext context, Exercise exercise) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary muscles
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Primary',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: AppColors.velvetMist,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...exercise.generalPrimaryMuscles.map((muscle) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          _getMuscleIconPath(muscle),
                          color: AppColors.velvetPale,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.fitness_center,
                              color: AppColors.velvetPale,
                              size: 20,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          muscle,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ],
          ),
        ),

        const SizedBox(width: 8), // Add space between columns

        // Secondary muscles (if any)
        if (exercise.generalSecondaryMuscles.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secondary',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: AppColors.velvetLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...exercise.generalSecondaryMuscles.map((muscle) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            _getMuscleIconPath(muscle),
                            color: AppColors.velvetLight,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.fitness_center,
                                color: AppColors.velvetLight,
                                size: 20,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            muscle,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Exercise exercise, ExerciseProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Add to workout button
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.fitness_center),
            label: const Text('Add to Workout'),
            onPressed: () {
              // This will be implemented in Phase 3
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${exercise.name} to workout'),
                  backgroundColor: AppColors.velvetPale,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.velvetPale,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Edit/Delete buttons for custom exercises
        if (exercise.isCustom) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editExercise(context, exercise),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.velvetHighlight,
            ),
            tooltip: 'Edit Exercise',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, exercise, provider),
            style: IconButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.8),
            ),
            tooltip: 'Delete Exercise',
          ),
        ],
      ],
    );
  }

  Widget _getCategoryImage(String category) {
    String imagePath;
    double size = 100;

    // Assign image path based on category
    switch (category.toLowerCase()) {
      case 'chest':
        imagePath = 'assets/icons/chest.png';
        break;
      case 'back':
        imagePath = 'assets/icons/back.png';
        break;
      case 'legs':
        imagePath = 'assets/icons/legs.png';
        break;
      case 'shoulders':
        imagePath = 'assets/icons/shoulders.png';
        break;
      case 'arms':
        imagePath = 'assets/icons/arms.png';
        break;
      case 'biceps':
        imagePath = 'assets/icons/arms.png'; // Use arms icon for biceps
        break;
      case 'triceps':
        imagePath = 'assets/icons/triceps.png';
        break;
      case 'forearms':
        imagePath = 'assets/icons/forearms.png';
        break;
      case 'neck':
        imagePath = 'assets/icons/neck.png';
        break;
      case 'core':
        imagePath = 'assets/icons/abs.png';
        break;
      case 'abs':
        imagePath = 'assets/icons/abs.png';
        break;
      case 'abdominals':
        imagePath = 'assets/icons/abs.png';
        break;
      case 'cardio':
        imagePath = 'assets/icons/cardio.png';
        break;
      default:
        imagePath = 'assets/icons/dumbbell.png';
    }

    return Image.asset(
      imagePath,
      width: size,
      height: size,
      color: Colors.white,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a basic icon if the image asset fails to load
        return Icon(
          MaterialCommunityIcons.dumbbell,
          size: size,
          color: Colors.white,
        );
      },
    );
  }

  String _getMuscleIconPath(String muscle) {
    // Map muscle names to icon paths
    final muscleLower = muscle.toLowerCase();

    if (muscleLower.contains('pectoralis') || muscleLower.contains('chest')) {
      return 'assets/icons/chest.png';
    } else if (muscleLower.contains('latissimus') || muscleLower == 'lats') {
      return 'assets/icons/lats.png';
    } else if (muscleLower.contains('trapezius') || muscleLower == 'traps') {
      return 'assets/icons/traps.png';
    } else if (muscleLower.contains('rhomboid')) {
      return 'assets/icons/back.png';
    } else if (muscleLower.contains('deltoid') || muscleLower.contains('shoulder')) {
      return 'assets/icons/shoulders.png';
    } else if (muscleLower.contains('triceps')) {
      return 'assets/icons/triceps.png';
    } else if (muscleLower.contains('biceps') || muscleLower.contains('brachii')) {
      return 'assets/icons/arms.png';
    } else if (muscleLower.contains('forearm') || muscleLower.contains('brachioradialis') ||
              muscleLower.contains('carpi') || muscleLower.contains('flexor') ||
              muscleLower.contains('extensor')) {
      return 'assets/icons/forearms.png';
    } else if (muscleLower.contains('quad') || muscleLower.contains('vastus')) {
      return 'assets/icons/quads.png';
    } else if (muscleLower.contains('hamstring')) {
      return 'assets/icons/hamstrings.png';
    } else if (muscleLower.contains('glute')) {
      return 'assets/icons/glutes.png';
    } else if (muscleLower.contains('calves') || muscleLower.contains('gastrocnemius') || muscleLower.contains('soleus')) {
      return 'assets/icons/calves.png';
    } else if (muscleLower.contains('abdominal') || muscleLower.contains('abs') || muscleLower.contains('rectus') || muscleLower.contains('oblique')) {
      return 'assets/icons/abs.png';
    } else if (muscleLower.contains('erector') || muscleLower.contains('spinae') || muscleLower.contains('lower back')) {
      return 'assets/icons/lower_back.png';
    } else if (muscleLower.contains('neck') || muscleLower.contains('sternocleidomastoid') || muscleLower.contains('cervical') || muscleLower.contains('scalene')) {
      return 'assets/icons/neck.png';
    }

    // Default generic muscle icon
    return 'assets/icons/muscle.png';
  }

  void _editExercise(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(exerciseToEdit: exercise),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Exercise exercise, ExerciseProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.royalVelvet,
          title: const Text('Delete Exercise'),
          content: Text(
            'Are you sure you want to delete ${exercise.name}?',
            style: const TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await provider.deleteExercise(exercise.id);
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to browse screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exercise deleted'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
