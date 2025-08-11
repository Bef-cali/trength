// lib/screens/split_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../models/workout_split.dart';
import '../models/workout_session.dart';
import 'session_edit_screen.dart';
import 'split_create_screen.dart';
import '../widgets/session_list_item.dart';
import '../theme/app_colors.dart';

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
            onPressed: () => _navigateToEditSplit(context),
          ),
        ],
      ),
      body: Consumer<SplitProvider>(
        builder: (context, splitProvider, child) {
          // Get the updated split from the provider
          final currentSplit = splitProvider.splits.firstWhere(
            (s) => s.id == split.id,
            orElse: () => split,
          );

          if (currentSplit.sessions.isEmpty) {
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
                    'No Workout Sessions',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.velvetLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a session to your split',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      color: AppColors.velvetLight.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _addNewSession(context, currentSplit),
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
                      'Add Session',
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
              if (currentSplit.description != null &&
                  currentSplit.description!.isNotEmpty)
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

              // Sessions - use ListView instead of ReorderableListView
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentSplit.sessions.length,
                  itemBuilder: (context, index) {
                    if (index >= currentSplit.sessions.length) {
                      return const SizedBox.shrink();
                    }

                    final session = currentSplit.sessions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SessionListItem(
                        key: ValueKey(session.id),
                        session: session,
                        onTap: () => _navigateToSessionEdit(
                          context,
                          currentSplit.id,
                          session,
                        ),
                        onDelete: () => _confirmDeleteSession(
                          context,
                          currentSplit.id,
                          session,
                          splitProvider,
                        ),
                        onReorder: (direction) {
                          // Handle reordering with buttons instead of drag
                          if (direction == ReorderDirection.up && index > 0) {
                            splitProvider.reorderSessions(
                              currentSplit.id,
                              index,
                              index - 1,
                            );
                          } else if (direction == ReorderDirection.down &&
                                    index < currentSplit.sessions.length - 1) {
                            splitProvider.reorderSessions(
                              currentSplit.id,
                              index,
                              index + 2, // +2 because Flutter adjusts the target index
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewSession(context, split),
        backgroundColor: AppColors.velvetPale,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToEditSplit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitCreateScreen(split: split),
      ),
    );
  }

  void _addNewSession(BuildContext context, WorkoutSplit split) {
    final sessionCount = split.sessions.length;
    final newSession = WorkoutSession(
      name: 'Session ${sessionCount + 1}',
      sequence: sessionCount,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionEditScreen(
          splitId: split.id,
          session: newSession,
          isNewSession: true,
        ),
      ),
    );
  }

  void _navigateToSessionEdit(
    BuildContext context,
    String splitId,
    WorkoutSession session,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionEditScreen(
          splitId: splitId,
          session: session,
        ),
      ),
    );
  }

  void _confirmDeleteSession(
    BuildContext context,
    String splitId,
    WorkoutSession session,
    SplitProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: const Text(
          'Delete Session',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${session.name}"?\nThis action cannot be undone.',
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
              provider.deleteSession(splitId, session.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Session "${session.name}" deleted',
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
}

// Define a simple enum for reordering direction
enum ReorderDirection {
  up,
  down,
}
