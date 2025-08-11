// lib/screens/progression_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/progression_settings.dart';
import '../providers/workout_provider.dart';
import '../theme/app_colors.dart';

class ProgressionSettingsScreen extends StatefulWidget {
  const ProgressionSettingsScreen({Key? key}) : super(key: key);

  @override
  _ProgressionSettingsScreenState createState() => _ProgressionSettingsScreenState();
}

class _ProgressionSettingsScreenState extends State<ProgressionSettingsScreen> {
  late ProgressionSettings _settings;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Fixed: Separate method to load settings to avoid initialization issues
  void _loadSettings() {
    if (!_settingsLoaded) {
      try {
        // Load current settings from provider
        final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
        final settingsMap = workoutProvider.getProgressionSettings();

        // Create settings object from the map
        setState(() {
          _settings = ProgressionSettings(
            weightIncrementKg: settingsMap['weightIncrementKg'],
            progressionStrategy: settingsMap['progressionStrategy'],
            minRepsBeforeWeightIncrease: settingsMap['minRepsBeforeWeightIncrease'],
            plateauThreshold: settingsMap['plateauThreshold'],
            deloadPercentage: settingsMap['deloadPercentage'],
            defaultRestTimeSeconds: settingsMap['defaultRestTimeSeconds'] ?? 90,
          );
          _settingsLoaded = true;
        });
      } catch (e) {
        // If settings couldn't be loaded, use defaults
        setState(() {
          _settings = ProgressionSettings();
          _settingsLoaded = true;
        });

        // Show error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not load settings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSaving = true;
      });

      try {
        // Save to provider
        final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
        await workoutProvider.saveProgressionSettings(_settings.toMap());

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully'),
              backgroundColor: AppColors.velvetPale,
              duration: Duration(seconds: 2),
            ),
          );

          // Fixed: Delay before changing state and navigation
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            setState(() {
              _isSaving = false;
            });

            // Fixed: We let the user manually navigate back or stay on the screen
            // by removing the automatic navigation
          }
        }
      } catch (e) {
        // Handle errors
        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving settings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fixed: Show loading indicator until settings are loaded
    if (!_settingsLoaded) {
      return Scaffold(
        backgroundColor: AppColors.deepVelvet,
        appBar: AppBar(
          title: const Text('Progression Settings'),
          backgroundColor: AppColors.royalVelvet,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.velvetPale),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return !_isSaving; // Prevent back navigation during save
      },
      child: Scaffold(
        backgroundColor: AppColors.deepVelvet,
        appBar: AppBar(
          title: const Text('Progression Settings'),
          backgroundColor: AppColors.royalVelvet,
          actions: [
            if (!_isSaving)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveSettings,
              ),
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
        body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.velvetPale),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Saving settings...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Progression strategy section
                  _buildSectionTitle('Progression Strategy'),
                  const SizedBox(height: 8),

                  _buildStrategyCard('weight_first', 'Weight First',
                      'Focus on adding weight when you reach target reps'),

                  _buildStrategyCard('reps_first', 'Reps First',
                      'Focus on increasing reps before adding weight'),

                  _buildStrategyCard('volume_first', 'Volume First',
                      'Alternate between reps and weight to maximize volume'),

                  const SizedBox(height: 24),

                  // Weight Increment Section
                  _buildSectionTitle('Weight Increment Settings'),
                  const SizedBox(height: 8),

                  Card(
                    color: AppColors.royalVelvet,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIncrementsSlider(
                            label: 'Weight Increment (kg)',
                            value: _settings.weightIncrementKg,
                            min: 0.5,
                            max: 10.0,
                            divisions: 19,
                            suffix: 'kg',
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(weightIncrementKg: value);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progression Details Section
                  _buildSectionTitle('Progression Details'),
                  const SizedBox(height: 8),

                  Card(
                    color: AppColors.royalVelvet,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minimum Reps Before Weight Increase',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),

                          _buildNumberSelector(
                            value: _settings.minRepsBeforeWeightIncrease,
                            min: 1,
                            max: 20,
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(minRepsBeforeWeightIncrease: value);
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Default Rest Timer (seconds)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),

                          _buildNumberSelector(
                            value: _settings.defaultRestTimeSeconds,
                            min: 30,
                            max: 240,
                            step: 10,
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(defaultRestTimeSeconds: value);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Plateau Detection Section
                  _buildSectionTitle('Plateau Detection & Deload'),
                  const SizedBox(height: 8),

                  Card(
                    color: AppColors.royalVelvet,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'These settings help you break through plateaus by suggesting deloads when progress stalls.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Workouts Without Progress for Plateau',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),

                          _buildNumberSelector(
                            value: _settings.plateauThreshold,
                            min: 2,
                            max: 10,
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(plateauThreshold: value);
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Deload Percentage',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),

                          Slider(
                            value: _settings.deloadPercentage * 100,
                            min: 5,
                            max: 30,
                            divisions: 5,
                            activeColor: AppColors.velvetPale,
                            inactiveColor: Colors.white24,
                            label: '${(_settings.deloadPercentage * 100).round()}%',
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(
                                  deloadPercentage: value / 100,
                                );
                              });
                            },
                          ),

                          Text(
                            '${(_settings.deloadPercentage * 100).round()}% reduction',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Removed the cancel button and simplified to just the save button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.velvetPale,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: AppColors.velvetPale.withOpacity(0.5),
                    ),
                    child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('SAVE SETTINGS'),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStrategyCard(String strategyValue, String title, String description) {
    final isSelected = _settings.progressionStrategy == strategyValue;

    return Card(
      color: isSelected ? AppColors.velvetHighlight : AppColors.royalVelvet,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.velvetPale : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _settings = _settings.copyWith(progressionStrategy: strategyValue);
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<String>(
                value: strategyValue,
                groupValue: _settings.progressionStrategy,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(progressionStrategy: value);
                  });
                },
                activeColor: AppColors.velvetMist,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncrementsSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: AppColors.velvetPale,
                inactiveColor: Colors.white24,
                label: '$value $suffix',
                onChanged: onChanged,
              ),
            ),
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.velvetHighlight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$value $suffix',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberSelector({
    required int value,
    required int min,
    required int max,
    int step = 1,
    required Function(int) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNumberButton(
            icon: Icons.remove,
            onPressed: value > min
                ? () => onChanged(value - step)
                : null,
          ),
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.velvetHighlight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildNumberButton(
            icon: Icons.add,
            onPressed: value < max
                ? () => onChanged(value + step)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: onPressed != null
            ? AppColors.velvetHighlight
            : AppColors.velvetHighlight.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}
