// lib/screens/session_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../providers/exercise_provider.dart';
import '../models/workout_session.dart';
import '../models/exercise_reference.dart';
import '../widgets/exercise_reference_item.dart';
import '../theme/app_colors.dart';
import 'exercise_selector_screen.dart';

class SessionEditScreen extends StatefulWidget {
  final String splitId;
  final WorkoutSession session;
  final bool isNewSession;

  const SessionEditScreen({
    Key? key,
    required this.splitId,
    required this.session,
    this.isNewSession = false,
  }) : super(key: key);

  @override
  _SessionEditScreenState createState() => _SessionEditScreenState();
}

class _SessionEditScreenState extends State<SessionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late List<ExerciseReference> _exercises;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.name);
    _notesController = TextEditingController(text: widget.session.notes ?? '');
    _exercises = List.from(widget.session.exercises);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: Text(
          widget.isNewSession ? 'New Session' : 'Edit Session',
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepVelvet,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSession,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name and notes fields
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.royalVelvet,
              child: Column(
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Session Name',
                      hintText: 'e.g., Push Day, Upper Body, Legs, etc.',
                      labelStyle: TextStyle(
                        color: AppColors.velvetLight,
                        fontFamily: 'Quicksand',
                      ),
                      hintStyle: TextStyle(
                        color: AppColors.velvetLight.withOpacity(0.5),
                        fontFamily: 'Quicksand',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.velvetHighlight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.velvetHighlight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.velvetPale, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.deepVelvet,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Quicksand',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name for this session';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add notes about this session',
                      labelStyle: TextStyle(
                        color: AppColors.velvetLight,
                        fontFamily: 'Quicksand',
                      ),
                      hintStyle: TextStyle(
                        color: AppColors.velvetLight.withOpacity(0.5),
                        fontFamily: 'Quicksand',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.velvetHighlight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.velvetHighlight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.velvetPale, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.deepVelvet,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Quicksand',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            // Exercise list
            Expanded(
              child: _exercises.isEmpty
                  ? _buildEmptyExercisesList()
                  : _buildExercisesList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToExerciseSelector(context),
        backgroundColor: AppColors.velvetPale,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyExercisesList() {
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
            'No Exercises Added',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.velvetLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add exercises',
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

  Widget _buildExercisesList(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _exercises.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _exercises.removeAt(oldIndex);
          _exercises.insert(newIndex, item);

          // Update order values
          for (int i = 0; i < _exercises.length; i++) {
            _exercises[i] = _exercises[i].copyWith(order: i);
          }
        });
      },
      itemBuilder: (context, index) {
        final exerciseRef = _exercises[index];
        final exercise = exerciseProvider.getExerciseById(exerciseRef.exerciseId);

        return ExerciseReferenceItem(
          key: ValueKey(exerciseRef.id),
          exerciseReference: exerciseRef,
          exercise: exercise,
          onDelete: () => _removeExercise(index),
          onEdit: () => _editExerciseReference(context, index, exerciseRef),
        );
      },
    );
  }

  void _navigateToExerciseSelector(BuildContext context) async {
    final selectedExerciseId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSelectorScreen(),
      ),
    );

    if (selectedExerciseId != null) {
      setState(() {
        _exercises.add(ExerciseReference(
          exerciseId: selectedExerciseId,
          order: _exercises.length,
        ));
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);

      // Update order values
      for (int i = 0; i < _exercises.length; i++) {
        _exercises[i] = _exercises[i].copyWith(order: i);
      }
    });
  }

  void _editExerciseReference(
    BuildContext context,
    int index,
    ExerciseReference reference,
  ) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final exercise = exerciseProvider.getExerciseById(reference.exerciseId);

    // Exercise might be null if it was deleted from the database
    final exerciseName = exercise?.name ?? 'Unknown Exercise';

    // Controllers for the form fields
    final setsController = TextEditingController(text: reference.targetSets?.toString() ?? '');
    final repsController = TextEditingController(text: reference.targetReps ?? '');
    final notesController = TextEditingController(text: reference.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: Text(
          exerciseName,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Target sets field
              TextField(
                controller: setsController,
                decoration: InputDecoration(
                  labelText: 'Target Sets',
                  labelStyle: TextStyle(
                    color: AppColors.velvetLight,
                    fontFamily: 'Quicksand',
                  ),
                  filled: true,
                  fillColor: AppColors.deepVelvet,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Target reps field
              TextField(
                controller: repsController,
                decoration: InputDecoration(
                  labelText: 'Target Reps (e.g., "8-12", "AMRAP")',
                  labelStyle: TextStyle(
                    color: AppColors.velvetLight,
                    fontFamily: 'Quicksand',
                  ),
                  filled: true,
                  fillColor: AppColors.deepVelvet,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                ),
              ),
              const SizedBox(height: 16),

              // Notes field
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(
                    color: AppColors.velvetLight,
                    fontFamily: 'Quicksand',
                  ),
                  filled: true,
                  fillColor: AppColors.deepVelvet,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                ),
                maxLines: 3,
              ),
            ],
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
              // Parse input values
              int? targetSets;
              if (setsController.text.trim().isNotEmpty) {
                targetSets = int.tryParse(setsController.text.trim());
              }

              String? targetReps;
              if (repsController.text.trim().isNotEmpty) {
                targetReps = repsController.text.trim();
              }

              String? notes;
              if (notesController.text.trim().isNotEmpty) {
                notes = notesController.text.trim();
              }

              // Update the exercise reference
              setState(() {
                _exercises[index] = reference.copyWith(
                  targetSets: targetSets,
                  targetReps: targetReps,
                  notes: notes,
                );
              });

              Navigator.of(ctx).pop();
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: AppColors.velvetPale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSession() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SplitProvider>(context, listen: false);

      try {
        final updatedSession = widget.session.copyWith(
          name: _nameController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          exercises: _exercises,
        );

        if (widget.isNewSession) {
          await provider.addSession(widget.splitId, updatedSession);
        } else {
          await provider.updateSession(widget.splitId, updatedSession);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isNewSession
                    ? 'Session "${updatedSession.name}" added'
                    : 'Session "${updatedSession.name}" updated',
                style: const TextStyle(fontFamily: 'Quicksand'),
              ),
              backgroundColor: AppColors.velvetHighlight,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save session: $e',
                style: const TextStyle(fontFamily: 'Quicksand'),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }
}
