// lib/screens/workout_start_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/split_provider.dart';
import '../providers/exercise_provider.dart';
import '../models/workout_split.dart';
import '../models/workout_session.dart';
import '../theme/app_colors.dart';
import 'active_workout_screen.dart';

class WorkoutStartScreen extends StatefulWidget {
  const WorkoutStartScreen({Key? key}) : super(key: key);

  @override
  _WorkoutStartScreenState createState() => _WorkoutStartScreenState();
}

class _WorkoutStartScreenState extends State<WorkoutStartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Changed from 3 to 2
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
      appBar: AppBar(
        title: const Text(
          'Start Workout',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.royalVelvet,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.velvetMist,
          labelColor: AppColors.velvetMist,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'From Split'),
            Tab(text: 'Empty'),
          ], // Removed 'Quick Start' tab
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFromSplitTab(),
          _buildEmptyTab(),
        ], // Removed _buildQuickStartTab()
      ),
    );
  }

  Widget _buildFromSplitTab() {
    return Consumer<SplitProvider>(
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
                  'No splits created yet',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.velvetLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a split first to start a workout',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    color: AppColors.velvetLight.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Split'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.velvetHighlight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    // Navigate to split creation screen
                    // Implementation depends on your navigation setup
                  },
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

  Widget _buildSplitCard(WorkoutSplit split) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.royalVelvet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Split header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  split.name,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (split.description != null && split.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      split.description!,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${split.sessions.length} sessions',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetPale,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Session list
          if (split.sessions.isNotEmpty) ...[
            const Divider(height: 1, color: Colors.white10),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: split.sessions.length,
              itemBuilder: (context, index) {
                final session = split.sessions[index];
                return _buildSessionItem(split, session);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionItem(WorkoutSplit split, WorkoutSession session) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final exerciseCount = session.exercises.length;

    // Get a preview of the first few exercises
    final exerciseNames = session.exercises.take(3).map((ref) {
      final exercise = exerciseProvider.getExerciseById(ref.exerciseId);
      return exercise?.name ?? 'Unknown Exercise';
    }).join(', ');

    // Add ellipsis if there are more exercises
    final exercisePreview = exerciseCount > 3
        ? '$exerciseNames, +${exerciseCount - 3} more'
        : exerciseNames;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        session.name,
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
            '$exerciseCount exercises',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              color: AppColors.velvetPale,
            ),
          ),
          if (exercisePreview.isNotEmpty)
            Text(
              exercisePreview,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: ElevatedButton(
        child: const Text('Start'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.velvetPale,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          _startWorkoutFromSession(split, session);
        },
      ),
      onTap: () {
        _startWorkoutFromSession(split, session);
      },
    );
  }

  Widget _buildEmptyTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 64,
            color: AppColors.velvetLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a blank workout',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.velvetLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a workout from scratch',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              color: AppColors.velvetLight.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Workout name input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              controller: TextEditingController(text: 'New Workout'),
              decoration: InputDecoration(
                labelText: 'Workout Name',
                labelStyle: TextStyle(color: AppColors.velvetLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.velvetLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.velvetPale),
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Quicksand',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _startEmptyWorkout(value);
                }
              },
            ),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Blank Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.velvetHighlight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: () {
              _startEmptyWorkout('New Workout');
            },
          ),
        ],
      ),
    );
  }

  void _startWorkoutFromSession(WorkoutSplit split, WorkoutSession session) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    workoutProvider.startWorkoutFromSplit(split, session).then((_) {
      // Navigate to the active workout screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ActiveWorkoutScreen(),
        ),
      );
    });
  }

  void _startEmptyWorkout(String name) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    workoutProvider.startEmptyWorkout(name).then((_) {
      // Navigate to the active workout screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ActiveWorkoutScreen(),
        ),
      );
    });
  }
}
