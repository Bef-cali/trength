// lib/widgets/exercise_set_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise_set.dart';
import '../theme/app_colors.dart';

class ExerciseSetCard extends StatefulWidget {
  final String exerciseId;
  final ExerciseSet set;
  final int setNumber;
  final Function(bool)? onSetCompleted;
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
    this.onSetCompleted,
    required this.onSetEdited,
    required this.onSetDeleted,
    this.isPR = false,
    this.progressComparison,
    this.showSuggestion = false,
  }) : super(key: key);

  @override
  _ExerciseSetCardState createState() => _ExerciseSetCardState();
}

class _ExerciseSetCardState extends State<ExerciseSetCard> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  
  late FocusNode _weightFocus;
  late FocusNode _repsFocus;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with proper empty state handling
    _weightController = TextEditingController(
      text: widget.set.weight == 0 ? '' : widget.set.weight.toString()
    );
    _repsController = TextEditingController(
      text: widget.set.reps == 0 ? '' : widget.set.reps.toString()
    );
    
    _weightFocus = FocusNode();
    _repsFocus = FocusNode();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }
  
  // Save changes when focus is lost or value changes
  void _onWeightChanged() {
    final newWeight = double.tryParse(_weightController.text);
    if (newWeight != null && newWeight >= 0) {
      final updatedSet = widget.set.copyWith(
        weight: newWeight,
        rpe: 8.0, // Default RPE to 8 for all working sets
      );
      widget.onSetEdited(updatedSet);
    }
  }
  
  void _onRepsChanged() {
    final newReps = int.tryParse(_repsController.text);
    if (newReps != null && newReps >= 0) {
      final updatedSet = widget.set.copyWith(
        reps: newReps,
        rpe: 8.0, // Default RPE to 8 for all working sets
      );
      widget.onSetEdited(updatedSet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.set.completed;
    final isWarmup = widget.set.isWarmup;
    final isDropSet = widget.set.isDropSet;

    // Determine card colors
    Color cardColor = AppColors.royalVelvet;
    if (isWarmup) {
      cardColor = AppColors.deepVelvet.withOpacity(0.7);
    } else if (isDropSet) {
      cardColor = AppColors.velvetHighlight.withOpacity(0.7);
    }

    if (isCompleted) {
      cardColor = cardColor.withOpacity(0.8);
    }

    // PR highlighting
    if (widget.isPR && isCompleted) {
      cardColor = AppColors.velvetPale.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced from 12
      child: Card(
        color: cardColor,
        elevation: isCompleted ? 1 : 2, // Reduced elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: widget.isPR && isCompleted
                ? AppColors.velvetMist
                : isCompleted
                    ? AppColors.velvetPale.withOpacity(0.3)
                    : Colors.transparent,
            width: widget.isPR && isCompleted ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12), // Reduced padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Set number
                  Container(
                    width: 32, // Restored to reduced size
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getSetNumberColor(),
                    ),
                    child: Center(
                      child: Text(
                        widget.setNumber.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Editable fields
                  Expanded(
                    child: Row(
                      children: [
                        // Weight field
                        _buildInputField(
                          controller: _weightController,
                          focusNode: _weightFocus,
                          fieldType: 'weight',
                          suffix: widget.set.weightUnit,
                          width: 65, // Reduced width to prevent layout conflicts
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          placeholder: '0',
                          onChanged: _onWeightChanged,
                        ),
                        
                        const SizedBox(width: 8),
                        const Text('×', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(width: 8),
                        
                        // Reps field  
                        _buildInputField(
                          controller: _repsController,
                          focusNode: _repsFocus,
                          fieldType: 'reps',
                          suffix: '',
                          width: 45, // Reduced width to fix checkbox conflict
                          keyboardType: TextInputType.number,
                          placeholder: '0',
                          onChanged: _onRepsChanged,
                        ),
                        
                        const SizedBox(width: 4),
                        const Text('reps', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        
                        // RPE removed - default to 8 in background
                      ],
                    ),
                  ),

                  // Progress indicator
                  if (widget.progressComparison != null && isCompleted)
                    _buildProgressIndicator(),

                  const SizedBox(width: 16),

                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.withOpacity(0.7),
                      size: 18, // Smaller icon
                    ),
                    onPressed: _showDeleteDialog,
                    tooltip: 'Delete Set',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // PR badge
            if (widget.isPR && isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.velvetMist,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'PR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

            // Set type indicators at bottom
            if (isWarmup || isDropSet)
              Positioned(
                bottom: 2,
                left: 48, // Position after set number
                child: Row(
                  children: [
                    if (isWarmup)
                      _buildTag('W', Colors.grey.withOpacity(0.8)),
                    if (isDropSet)
                      _buildTag('D', AppColors.velvetPale.withOpacity(0.8)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String fieldType,
    required String suffix,
    required double width,
    required TextInputType keyboardType,
    required String placeholder,
    required VoidCallback onChanged,
  }) {
    return Container(
      width: width,
      height: 36,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.velvetPale),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          hintText: placeholder,
          hintStyle: const TextStyle(color: Colors.white38),
          suffixText: suffix.isNotEmpty ? suffix : null,
          suffixStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        onChanged: (_) => onChanged(),
        onSubmitted: (_) {
          _nextField(fieldType);
        },
      ),
    );
  }
  
  
  void _nextField(String currentField) {
    switch (currentField) {
      case 'weight':
        _repsFocus.requestFocus();
        break;
      case 'reps':
        FocusScope.of(context).unfocus(); // Close keyboard after reps
        break;
    }
  }

  Widget _buildProgressIndicator() {
    final comparison = widget.progressComparison!;
    if (comparison['isFirstTime'] == true || comparison['isDifferentUnit'] == true) {
      return const SizedBox.shrink();
    }

    final weightDiff = comparison['weightDiff'] as double;
    final repsDiff = comparison['repsDiff'] as int;

    IconData icon;
    Color color;
    
    if (weightDiff > 0) {
      icon = Icons.trending_up;
      color = AppColors.velvetMist;
    } else if (weightDiff < 0) {
      icon = Icons.trending_down;
      color = Colors.orangeAccent;
    } else if (repsDiff > 0) {
      icon = Icons.add;
      color = AppColors.velvetPale;
    } else if (repsDiff < 0) {
      icon = Icons.remove;
      color = Colors.grey;
    } else {
      return const SizedBox.shrink();
    }

    return Icon(icon, color: color, size: 16);
  }

  Color _getSetNumberColor() {
    if (widget.set.isWarmup) return Colors.grey;
    if (widget.set.isDropSet) return AppColors.velvetPale;
    if (widget.isPR && widget.set.completed) return AppColors.velvetMist;
    return AppColors.velvetHighlight;
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.royalVelvet,
        title: const Text('Delete Set', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this set?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              widget.onSetDeleted();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}