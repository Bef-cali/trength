import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_model.dart';
import '../providers/exercise_provider.dart';
import '../theme/app_colors.dart';

class AddExerciseScreen extends StatefulWidget {
  final Exercise? exerciseToEdit;

  const AddExerciseScreen({
    Key? key,
    this.exerciseToEdit,
  }) : super(key: key);

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form state
  String _selectedCategory = 'Chest';
  String _selectedEquipment = 'Barbell';
  List<String> _selectedPrimaryMuscles = [];
  List<String> _selectedSecondaryMuscles = [];

  // Predefined lists
  final List<String> _categories = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Biceps', 'Triceps', 'Forearms',
    'Neck', 'Core', 'Abs', 'Cardio', 'Other'
  ];

  final List<String> _equipmentTypes = [
    'Barbell', 'Dumbbell', 'Machine', 'Cable', 'Bodyweight', 'Kettlebell', 'Resistance Band', 'Other'
  ];

  final List<String> _muscleGroups = [
    'Pectoralis Major', 'Pectoralis Minor', 'Latissimus Dorsi', 'Trapezius',
    'Rhomboids', 'Deltoids', 'Triceps Brachii', 'Biceps Brachii', 'Forearms', 'Quadriceps',
    'Hamstrings', 'Glutes', 'Calves', 'Abdominals', 'Obliques', 'Erector Spinae',
    'Anterior Deltoid', 'Lateral Deltoid', 'Posterior Deltoid', 'Sternocleidomastoid',
    'Scalenes', 'Levator Scapulae', 'Rectus Abdominis', 'Transverse Abdominis',
    'Gluteus Maximus', 'Gluteus Medius', 'Gluteus Minimus', 'Gastrocnemius', 'Soleus',
    'Hip Flexors', 'Brachialis', 'Brachioradialis', 'Teres Major', 'Teres Minor',
    'Infraspinatus', 'Supraspinatus', 'Subscapularis', 'Serratus Anterior',
    'Flexor Carpi Radialis', 'Flexor Carpi Ulnaris', 'Extensor Carpi Radialis', 'Extensor Carpi Ulnaris'
  ];

  @override
  void initState() {
    super.initState();

    // If editing an existing exercise, populate the form fields
    if (widget.exerciseToEdit != null) {
      _nameController.text = widget.exerciseToEdit!.name;
      _descriptionController.text = widget.exerciseToEdit!.description ?? '';
      _selectedCategory = widget.exerciseToEdit!.category;
      _selectedEquipment = widget.exerciseToEdit!.equipment ?? _equipmentTypes[0];
      _selectedPrimaryMuscles = List.from(widget.exerciseToEdit!.primaryMuscles);
      _selectedSecondaryMuscles = List.from(widget.exerciseToEdit!.secondaryMuscles);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepVelvet,
      appBar: AppBar(
        title: Text(widget.exerciseToEdit != null ? 'Edit Exercise' : 'Add Exercise'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _saveExercise,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'Enter exercise name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Equipment dropdown
              DropdownButtonFormField<String>(
                value: _selectedEquipment,
                decoration: const InputDecoration(
                  labelText: 'Equipment',
                ),
                items: _equipmentTypes.map((equipment) {
                  return DropdownMenuItem(
                    value: equipment,
                    child: Text(equipment),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEquipment = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Primary muscles section
              Text(
                'Primary Muscles Targeted',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.velvetPale,
                ),
              ),
              const SizedBox(height: 8),
              _buildMuscleSelectionSection(_muscleGroups, _selectedPrimaryMuscles, true),

              // Error message if no primary muscles selected
              if (_selectedPrimaryMuscles.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'Please select at least one primary muscle',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Secondary muscles section
              Text(
                'Secondary Muscles Targeted (Optional)',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.velvetLight,
                ),
              ),
              const SizedBox(height: 8),
              _buildMuscleSelectionSection(
                _muscleGroups.where((m) => !_selectedPrimaryMuscles.contains(m)).toList(),
                _selectedSecondaryMuscles,
                false
              ),
              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter exercise description, form tips, etc.',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(widget.exerciseToEdit != null ? 'Update Exercise' : 'Save Exercise'),
                  onPressed: _saveExercise,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleSelectionSection(List<String> muscles, List<String> selectedMuscles, bool isPrimary) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: muscles.map((muscle) {
        bool isSelected = selectedMuscles.contains(muscle);
        return FilterChip(
          label: Text(muscle),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                // Adding to selected list
                if (isPrimary) {
                  // If adding to primary, remove from secondary if present
                  _selectedPrimaryMuscles.add(muscle);
                  _selectedSecondaryMuscles.remove(muscle);
                } else {
                  // If adding to secondary, remove from primary if present
                  _selectedSecondaryMuscles.add(muscle);
                  _selectedPrimaryMuscles.remove(muscle);
                }
              } else {
                // Removing from selected list
                if (isPrimary) {
                  _selectedPrimaryMuscles.remove(muscle);
                } else {
                  _selectedSecondaryMuscles.remove(muscle);
                }
              }
            });
          },
          backgroundColor: AppColors.deepVelvet,
          selectedColor: isPrimary
              ? AppColors.velvetPale.withOpacity(0.3)
              : AppColors.velvetLight.withOpacity(0.3),
          checkmarkColor: isPrimary ? AppColors.velvetPale : AppColors.velvetLight,
        );
      }).toList(),
    );
  }

  void _saveExercise() {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate primary muscles
    if (_selectedPrimaryMuscles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one primary muscle'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    if (widget.exerciseToEdit != null) {
      // Update existing exercise
      final updatedExercise = Exercise(
        id: widget.exerciseToEdit!.id,
        name: _nameController.text,
        category: _selectedCategory,
        primaryMuscles: _selectedPrimaryMuscles,
        secondaryMuscles: _selectedSecondaryMuscles,
        isCustom: true,
        userId: 'user123', // In a real app, this would be the current user's ID
        createdAt: widget.exerciseToEdit!.createdAt,
        equipment: _selectedEquipment,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );

      exerciseProvider.updateExercise(updatedExercise).then((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedExercise.name} updated'),
            backgroundColor: AppColors.velvetPale,
          ),
        );
      });
    } else {
      // Create new exercise
      final newExercise = Exercise(
        name: _nameController.text,
        category: _selectedCategory,
        primaryMuscles: _selectedPrimaryMuscles,
        secondaryMuscles: _selectedSecondaryMuscles,
        isCustom: true,
        userId: 'user123', // In a real app, this would be the current user's ID
        equipment: _selectedEquipment,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );

      exerciseProvider.addExercise(newExercise).then((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newExercise.name} added'),
            backgroundColor: AppColors.velvetPale,
          ),
        );
      });
    }
  }
}
