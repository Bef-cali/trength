// lib/screens/split_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../models/workout_split.dart';
import 'split_detail_screen.dart';
import 'split_create_screen.dart';
import '../widgets/split_list_item.dart';
import '../theme/app_colors.dart';

class SplitListScreen extends StatelessWidget {
  const SplitListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: const Text(
          'Workout Splits',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepVelvet,
        elevation: 0,
      ),
      body: Consumer<SplitProvider>(
        builder: (context, splitProvider, child) {
          if (splitProvider.splits.isEmpty) {
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
                    'No Workout Splits',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.velvetLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first workout split to get started',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetLight.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SplitCreateScreen(),
                        ),
                      );
                    },
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
                      'Create Split',
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: splitProvider.splits.length,
            itemBuilder: (context, index) {
              final split = splitProvider.splits[index];
              return SplitListItem(
                split: split,
                onTap: () {
                  splitProvider.setCurrentSplit(split.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitDetailScreen(split: split),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitCreateScreen(split: split),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, split, splitProvider),
                onDuplicate: () => _duplicateSplit(context, split.id, splitProvider),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SplitCreateScreen(),
            ),
          );
        },
        backgroundColor: AppColors.velvetPale,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WorkoutSplit split,
    SplitProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: const Text(
          'Delete Split',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${split.name}"?\nThis action cannot be undone.',
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
            onPressed: () {
              provider.deleteSplit(split.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Split "${split.name}" deleted',
                    style: const TextStyle(fontFamily: 'Quicksand'),
                  ),
                  backgroundColor: AppColors.velvetHighlight,
                ),
              );
            },
            child: const Text(
              'Delete',
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

  Future<void> _duplicateSplit(
    BuildContext context,
    String splitId,
    SplitProvider provider,
  ) async {
    try {
      final duplicate = await provider.duplicateSplit(splitId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Split "${duplicate.name}" created',
            style: const TextStyle(fontFamily: 'Quicksand'),
          ),
          backgroundColor: AppColors.velvetHighlight,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to duplicate split: $e',
            style: const TextStyle(fontFamily: 'Quicksand'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
