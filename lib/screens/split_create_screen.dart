// lib/screens/split_create_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split_provider.dart';
import '../models/workout_split.dart';
import '../theme/app_colors.dart';

class SplitCreateScreen extends StatefulWidget {
  final WorkoutSplit? split;

  const SplitCreateScreen({Key? key, this.split}) : super(key: key);

  @override
  _SplitCreateScreenState createState() => _SplitCreateScreenState();
}

class _SplitCreateScreenState extends State<SplitCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.split != null;
    _nameController = TextEditingController(text: widget.split?.name ?? '');
    _descriptionController = TextEditingController(text: widget.split?.description ?? '');
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
        title: Text(
          _isEditing ? 'Edit Split' : 'Create Split',
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepVelvet,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Split Name',
                hintText: 'e.g., Push Pull Legs, Upper/Lower, etc.',
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
                  return 'Please enter a name for your split';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add notes about this workout split',
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
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveSplit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.velvetPale,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isEditing ? 'Update Split' : 'Create Split',
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSplit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SplitProvider>(context, listen: false);

      try {
        if (_isEditing && widget.split != null) {
          final updatedSplit = widget.split!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
          );
          await provider.updateSplit(updatedSplit);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Split "${updatedSplit.name}" updated',
                  style: const TextStyle(fontFamily: 'Quicksand'),
                ),
                backgroundColor: AppColors.velvetHighlight,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          final newSplit = await provider.createSplit(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Split "${newSplit.name}" created',
                  style: const TextStyle(fontFamily: 'Quicksand'),
                ),
                backgroundColor: AppColors.velvetHighlight,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save split: $e',
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
