// lib/widgets/exercise_set_card.dart
import 'package:flutter/material.dart';
import '../models/exercise_set.dart';
import '../theme/app_colors.dart';

class ExerciseSetCard extends StatelessWidget {
  final String exerciseId;
  final ExerciseSet set;
  final int setNumber;
  final Function(bool) onSetCompleted;
  final Function(ExerciseSet) onSetEdited;
  final VoidCallback onSetDeleted;

  // Progressive overload related properties
  final bool isPR;
  final Map<String, dynamic>? progressComparison;
  final bool showSuggestion;

  const ExerciseSetCard({
    Key? key,
    required this.exerciseId,
    required this.set,
    required this.setNumber,
    required this.onSetCompleted,
    required this.onSetEdited,
    required this.onSetDeleted,
    this.isPR = false,
    this.progressComparison,
    this.showSuggestion = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = set.completed;
    final isWarmup = set.isWarmup;
    final isDropSet = set.isDropSet;

    // Determine the card color based on the set type and completion status
    Color cardColor = AppColors.royalVelvet;
    if (isWarmup) {
      cardColor = AppColors.deepVelvet.withOpacity(0.7);
    } else if (isDropSet) {
      cardColor = AppColors.velvetHighlight.withOpacity(0.7);
    }

    // If completed, apply a slight overlay
    if (isCompleted) {
      cardColor = cardColor.withOpacity(0.8);
    }

    // If it's a PR, add a special glow/highlight
    if (isPR && isCompleted) {
      cardColor = AppColors.velvetPale.withOpacity(0.3);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: cardColor,
        elevation: isCompleted ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPR && isCompleted
                ? AppColors.velvetMist
                : isCompleted
                    ? AppColors.velvetPale
                    : Colors.transparent,
            width: isPR && isCompleted ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showEditSetDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Set number column
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getSetNumberColor(),
                      ),
                      child: Center(
                        child: Text(
                          setNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Set details column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weight and reps
                          Row(
                            children: [
                              Text(
                                '${set.weight} ${set.weightUnit}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted
                                      ? TextDecoration.none
                                      : TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '× ${set.reps}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  decoration: isCompleted
                                      ? TextDecoration.none
                                      : TextDecoration.none,
                                ),
                              ),
                              if (set.rpe != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '@${set.rpe}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    decoration: isCompleted
                                        ? TextDecoration.none
                                        : TextDecoration.none,
                                  ),
                                ),
                              ],

                              // Progress comparison indicator
                              if (progressComparison != null && isCompleted) ...[
                                const SizedBox(width: 8),
                                _buildProgressIndicator(progressComparison!),
                              ],
                            ],
                          ),

                          // Set type indicators
                          if (isWarmup || isDropSet || set.notes != null || (progressComparison != null && isCompleted))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  if (isWarmup)
                                    _buildTag('Warmup', Colors.grey),
                                  if (isDropSet)
                                    _buildTag('Drop Set', AppColors.velvetPale),
                                  if (isPR && isCompleted)
                                    _buildTag('PR', AppColors.velvetMist),
                                  if (progressComparison != null && isCompleted && progressComparison?['volumePercentChange'] != null)
                                    _buildProgressTag(progressComparison!),
                                  if (set.notes != null && set.notes!.isNotEmpty)
                                    Expanded(
                                      child: Text(
                                        set.notes!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Completed checkbox
                    Checkbox(
                      value: isCompleted,
                      onChanged: (value) {
                        onSetCompleted(value ?? false);
                      },
                      activeColor: AppColors.velvetPale,
                      checkColor: Colors.white,
                    ),

                    // Options menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.velvetLight,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditSetDialog(context);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Set'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Set'),
                        ),
                      ],
                      color: AppColors.royalVelvet,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PR badge
            if (isPR && isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.velvetMist,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'PR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

            // Suggestion indicator
            if (showSuggestion)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.velvetPale.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSetNumberColor() {
    if (set.isWarmup) {
      return Colors.grey;
    }
    if (set.isDropSet) {
      return AppColors.velvetPale;
    }
    if (isPR && set.completed) {
      return AppColors.velvetMist;
    }
    return AppColors.velvetHighlight;
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressTag(Map<String, dynamic> progress) {
    final percentChange = progress['volumePercentChange'] as double;
    final isPositive = percentChange > 0;
    final color = isPositive ? AppColors.velvetPale : Colors.grey;
    final sign = isPositive ? '+' : '';
    final text = '$sign${percentChange.toStringAsFixed(1)}%';

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> progress) {
    if (progress['isFirstTime'] == true || progress['isDifferentUnit'] == true) {
      return const SizedBox.shrink();
    }

    final weightDiff = progress['weightDiff'] as double;
    final repsDiff = progress['repsDiff'] as int;

    if (weightDiff == 0 && repsDiff == 0) {
      return const SizedBox.shrink();
    }

    IconData icon;
    Color color;

    if (weightDiff > 0) {
      icon = Icons.arrow_upward;
      color = AppColors.velvetMist;
    } else if (weightDiff < 0) {
      icon = Icons.arrow_downward;
      color = Colors.grey;
    } else if (repsDiff > 0) {
      icon = Icons.arrow_upward;
      color = AppColors.velvetPale;
    } else {
      icon = Icons.arrow_downward;
      color = Colors.grey;
    }

    return Icon(
      icon,
      color: color,
      size: 16,
    );
  }

  void _showEditSetDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    double weight = set.weight;
    int reps = set.reps;
    double? rpe = set.rpe;
    bool isWarmup = set.isWarmup;
    bool isDropSet = set.isDropSet;
    String? notes = set.notes;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: const Text(
          'Edit Set',
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Weight input
                TextFormField(
                  initialValue: weight.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    weight = double.parse(value!);
                  },
                ),
                const SizedBox(height: 16),

                // Reps input
                TextFormField(
                  initialValue: reps.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reps';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    reps = int.parse(value!);
                  },
                ),
                const SizedBox(height: 16),

                // RPE input
                TextFormField(
                  initialValue: rpe?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RPE (optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    hintText: '1-10',
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final rpeValue = double.tryParse(value);
                      if (rpeValue == null) {
                        return 'Please enter a valid number';
                      }
                      if (rpeValue < 1 || rpeValue > 10) {
                        return 'RPE must be between 1 and 10';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      rpe = double.parse(value);
                    } else {
                      rpe = null;
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Notes input
                TextFormField(
                  initialValue: notes ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  onSaved: (value) {
                    notes = value?.trim().isNotEmpty == true ? value : null;
                  },
                ),
                const SizedBox(height: 16),

                // Set type toggles
                SwitchListTile(
                  title: const Text(
                    'Warmup Set',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: isWarmup,
                  activeColor: AppColors.velvetPale,
                  onChanged: (value) {
                    // If turning on warmup, turn off dropset
                    if (value && isDropSet) {
                      isDropSet = false;
                    }
                    isWarmup = value;
                  },
                ),

                SwitchListTile(
                  title: const Text(
                    'Drop Set',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: isDropSet,
                  activeColor: AppColors.velvetPale,
                  onChanged: (value) {
                    // If turning on dropset, turn off warmup
                    if (value && isWarmup) {
                      isWarmup = false;
                    }
                    isDropSet = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.velvetMist),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                // Update the set
                final updatedSet = set.copyWith(
                  weight: weight,
                  reps: reps,
                  rpe: rpe,
                  isWarmup: isWarmup,
                  isDropSet: isDropSet,
                  notes: notes,
                );

                onSetEdited(updatedSet);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: const Text(
          'Delete Set',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this set?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              onSetDeleted();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
